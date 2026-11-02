// cspell:ignore Tafsiri majaribio
/**
 * The seam to the AI service for the appointment and conversation domains. It extends the case
 * client without touching it: a deployment that has no speech or intake model simply leaves the
 * methods out, and the handlers record `Failed` (R-5) so the human path carries on.
 */
import type { AiClient } from './ai';

export interface DomainAiClient extends AiClient {
  /**
   * Reads de-identified text only. `languageHint` is the transcript's detected language, if any;
   * `inputLanguage` is the language the model found the text in.
   */
  summarizeSymptoms?(req: {
    inputText: string;
    languageHint?: string;
  }): Promise<{ en: string; sw: string; models: Record<string, string>; inputLanguage?: string }>;
  /** Reads the audio and nothing else: no name, id or text travels with it. */
  transcribeAudio?(req: {
    bytes: Buffer;
    contentType: string;
  }): Promise<{ transcript: string; language: string; models: Record<string, string> }>;
}

/** Fixtures only: it never leaves the process. Tests inject their own fakes for failures. */
export const stubDomainAiClient: DomainAiClient = {
  assessCase: () =>
    Promise.resolve({
      inputLanguage: '',
      suggestedLabTestIds: [],
      advisoryKey: '',
      translation: { language: 'sw', text: '' },
      models: { stub: 'fixture' },
    }),
  summarizeSymptoms: ({ inputText }) =>
    Promise.resolve({ en: inputText, sw: `Muhtasari: ${inputText}`, models: { stub: 'fixture' } }),
  transcribeAudio: () =>
    Promise.resolve({ transcript: 'Nina maumivu ya kichwa.', language: 'sw', models: { stub: 'fixture' } }),
};

export const AI_TIMEOUT_MS = 60_000;

/** A model call that hangs is a failure, not a stuck trigger (R-5). */
export function withTimeout<T>(work: Promise<T>, ms = AI_TIMEOUT_MS): Promise<T> {
  let timer: NodeJS.Timeout | undefined;
  const limit = new Promise<never>((_, reject) => {
    timer = setTimeout(() => reject(new Error('timeout')), ms);
  });
  return Promise.race([work, limit]).finally(() => clearTimeout(timer));
}
