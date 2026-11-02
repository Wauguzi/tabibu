import assert from 'node:assert/strict';

import { isEnabled, remoteConfigReader, type ServerTemplateLike } from './config';

function template(values: { on: boolean }, state: { failing: boolean }): ServerTemplateLike {
  return {
    load() {
      return state.failing ? Promise.reject(new Error('unreachable')) : Promise.resolve();
    },
    evaluate: () => ({ getBoolean: () => values.on }),
  };
}

describe('remoteConfigReader', () => {
  it('reads off before the first load', () => {
    const reader = remoteConfigReader(template({ on: true }, { failing: false }));
    assert.equal(reader.enabled('preread_enabled'), false);
  });

  it('reads the switch after a load', async () => {
    const reader = remoteConfigReader(template({ on: true }, { failing: false }));
    await reader.refresh();
    assert.equal(reader.enabled('preread_enabled'), true);
  });

  it('keeps the cache through a short outage and drops it after several periods', async () => {
    let now = 1_000_000;
    const state = { failing: false };
    const reader = remoteConfigReader(template({ on: true }, state), 60_000, () => now);
    await reader.refresh();
    state.failing = true;

    now += 3 * 60_000;
    await reader.refresh();
    assert.equal(reader.enabled('preread_enabled'), true);

    now += 3 * 60_000;
    await reader.refresh();
    assert.equal(reader.enabled('preread_enabled'), false);

    state.failing = false;
    await reader.refresh();
    assert.equal(reader.enabled('preread_enabled'), true);
  });

  it('isEnabled fails closed for no reader and for a throwing one', () => {
    assert.equal(isEnabled(undefined, 'x'), false);
    assert.equal(
      isEnabled(
        {
          enabled: () => {
            throw new Error('boom');
          },
        },
        'x',
      ),
      false,
    );
  });
});
