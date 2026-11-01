// cspell:ignore Wanjiru Kamau Baraka Mwangi naitwa Achieng kitambulisho tarehe Mgonjwa maumivu
// cspell:ignore Kiprop langu NHIF deidentify
import assert from 'node:assert/strict';

import { deidentify } from './deidentify';

describe('deidentify', () => {
  const rows: {
    name: string;
    text: string;
    expectGone?: RegExp;
    expectKeep?: RegExp;
    subject?: Parameters<typeof deidentify>[1];
  }[] = [
    {
      name: 'English name',
      text: 'Patient Amina Otieno reports fever',
      expectGone: /Amina|Otieno/,
      subject: { firstName: 'Amina', lastName: 'Otieno' },
    },
    {
      name: 'Swahili name',
      text: 'Mgonjwa Juma Kiprop ana maumivu',
      expectGone: /Juma|Kiprop/,
      subject: { firstName: 'Juma', lastName: 'Kiprop' },
    },
    {
      name: 'Ali must not touch malignant',
      text: 'malignant cells noted',
      expectKeep: /malignant/,
      subject: { firstName: 'Ali' },
    },
    {
      name: 'Eve must not touch fever',
      text: 'fever for 3 days',
      expectKeep: /fever/,
      subject: { firstName: 'Eve' },
    },
    {
      name: 'Kenyan phone 07',
      text: 'Call me on 0712345678 please',
      expectGone: /0712345678/,
    },
    {
      name: 'spaced phone 07',
      text: 'Call 07 12 34 56 78 please',
      expectGone: /07 12 34 56 78/,
    },
    {
      name: 'dashed phone',
      text: 'Reach 0712-345-678 today',
      expectGone: /0712-345-678/,
    },
    {
      name: 'Kenyan phone +254 spaced',
      text: 'Phone +254 712 345 678 noted',
      expectGone: /\+254 712 345 678/,
    },
    {
      name: 'email',
      text: 'Write to amina@example.com today',
      expectGone: /amina@example\.com/,
    },
    {
      name: 'ISO date',
      text: 'Born 1990-05-14 in Nairobi',
      expectGone: /1990-05-14/,
      subject: { dateOfBirth: '1990-05-14', county: 'Nairobi' },
    },
    {
      name: 'slash date',
      text: 'DOB 14/05/1990 recorded',
      expectGone: /14\/05\/1990/,
    },
    {
      name: 'English month date',
      text: 'Born 14 May 1990',
      expectGone: /14 May 1990/,
    },
    {
      name: 'Kiswahili month date',
      text: 'tarehe 14 Mei 1990',
      expectGone: /14 Mei 1990/,
    },
    {
      name: 'my name is',
      text: 'My name is Wanjiru Kamau and I feel ill',
      expectGone: /Wanjiru|Kamau/,
    },
    {
      name: 'jina langu ni',
      text: 'jina langu ni Baraka Mwangi',
      expectGone: /Baraka|Mwangi/,
    },
    {
      name: 'naitwa',
      text: 'naitwa Achieng today',
      expectGone: /Achieng/,
    },
    {
      name: 'NHIF number',
      text: 'ID 23456789 and NHIF 1234567 on file',
      expectGone: /23456789|1234567/,
    },
    {
      name: 'order number',
      text: 'Case TBB-20261027-0042 ready',
      expectGone: /TBB-20261027-0042/,
    },
    {
      name: 'facility from catalogue',
      text: 'Seen at Kenyatta National Hospital yesterday',
      expectGone: /Kenyatta National Hospital/,
    },
    {
      name: 'doses and durations survive',
      text: 'Give 500 mg for 3 days, x2 daily, Hb 10.2 g/dL',
      expectKeep: /500 mg|3 days|x2 daily|10\.2/,
    },
  ];

  for (const row of rows) {
    it(row.name, () => {
      const out = deidentify(row.text, row.subject);
      if (row.expectGone) assert.equal(row.expectGone.test(out), false, out);
      if (row.expectKeep) assert.equal(row.expectKeep.test(out), true, out);
    });
  }
});
