/**
 * Server-side Remote Config kill switches (plan R-8). Every AI-job switch fails closed: when the
 * template cannot be read, no new job starts and the human path carries on.
 */

export const KILL_SWITCHES = [
  'preread_enabled',
  'risk_check_enabled',
  'patient_explanations_enabled',
  'report_translation_enabled',
  'alerts_delivery_enabled',
  'symptom_intake_enabled',
  'voice_input_enabled',
  'alert_drafting_enabled',
] as const;

export interface ConfigReader {
  enabled(key: string): boolean;
}

/** What a missing or broken reader means: everything is off. */
export const failClosed: ConfigReader = { enabled: () => false };

/** The only way a handler asks a switch: a missing reader, a throw or a non-`true` is off. */
export function isEnabled(config: ConfigReader | undefined, key: string): boolean {
  if (!config) return false;
  try {
    return config.enabled(key) === true;
  } catch {
    return false;
  }
}

/** The slice of the Admin SDK's server template this module needs. */
export interface ServerTemplateLike {
  load(): Promise<void>;
  evaluate(): { getBoolean(key: string): boolean };
}

export interface RefreshableConfig extends ConfigReader {
  refresh(): Promise<void>;
}

/** How many refresh periods a template may go stale before its values stop being trusted. */
export const STALE_AFTER_PERIODS = 5;

/**
 * A synchronous reader over a server template, reloaded at most once per `maxAgeMs`. Before the
 * first load every switch reads off. A template that has not loaded for `STALE_AFTER_PERIODS`
 * periods is dropped, so a switch turned off while the service was unreachable is not read as on
 * from memory (R-8).
 */
export function remoteConfigReader(
  template: ServerTemplateLike,
  maxAgeMs = 60_000,
  clock: () => number = Date.now,
): RefreshableConfig {
  let loadedAt = 0;
  return {
    enabled(key: string): boolean {
      if (loadedAt === 0 || clock() - loadedAt > maxAgeMs * STALE_AFTER_PERIODS) return false;
      try {
        return template.evaluate().getBoolean(key) === true;
      } catch {
        return false;
      }
    },
    async refresh(): Promise<void> {
      if (loadedAt !== 0 && clock() - loadedAt < maxAgeMs) return;
      try {
        await template.load();
        loadedAt = clock();
      } catch {
        // Keep the cache for now; `enabled` stops trusting it once it is too old.
      }
    },
  };
}
