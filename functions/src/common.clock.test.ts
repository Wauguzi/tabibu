import assert from 'node:assert/strict';

import { nairobiDate, nairobiDayKey, nairobiHourKey } from './common';

describe('Nairobi clock', () => {
  it('shifts UTC into East Africa Time', () => {
    const late = new Date('2026-10-27T22:30:00.000Z');
    assert.equal(nairobiDate(late), '2026-10-28');
    assert.equal(nairobiDayKey(late), '20261028');
    assert.equal(nairobiHourKey(late), '2026102801');
  });

  it('crosses midnight at 21:00Z', () => {
    assert.equal(nairobiDate(new Date('2026-10-27T20:59:59.000Z')), '2026-10-27');
    assert.equal(nairobiHourKey(new Date('2026-10-27T20:59:59.000Z')), '2026102723');
    assert.equal(nairobiDate(new Date('2026-10-27T21:00:00.000Z')), '2026-10-28');
    assert.equal(nairobiHourKey(new Date('2026-10-27T21:00:00.000Z')), '2026102800');
  });

  it('rolls the year at 21:00Z on 31 December', () => {
    assert.equal(nairobiDate(new Date('2026-12-31T21:00:00.000Z')), '2027-01-01');
    assert.equal(nairobiDayKey(new Date('2026-12-31T21:00:00.000Z')), '20270101');
  });
});
