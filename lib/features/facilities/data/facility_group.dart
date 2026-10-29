/// The facility list groups behind its filter chips. Nursing homes count
/// as hospitals, and Medical Center as a health centre.
enum FacilityGroup { hospital, healthCentre, clinic, dispensary, laboratory }

/// The group for a `facilityType` from `assets/data/facilities_nairobi.json`,
/// or null when the type is never listed (pharmacies, farewell homes) or
/// unknown.
FacilityGroup? facilityGroupOf(String facilityType) => switch (facilityType) {
  'Primary care hospitals' ||
  'Secondary care hospitals' ||
  'Specialized & Tertiary Referral hospitals' ||
  'Comprehensive Teaching & Tertiary Referral Hospital' ||
  'HOSPITALS' ||
  'Hospital' ||
  'Nursing Homes' ||
  'Nursing and Maternity Home' => .hospital,
  'Basic Health Centre' ||
  'Comprehensive Health Centre' ||
  'HEALTH CENTRE' ||
  'Medical Center' => .healthCentre,
  'Medical Clinic' ||
  'VCT' ||
  'Dental Clinic' ||
  'Ophthalmology' ||
  'Dialysis Center' ||
  'Radiology Clinic' ||
  'Rehab. Center - Drug and Substance abuse' => .clinic,
  'Dispensary' => .dispensary,
  'Laboratory' => .laboratory,
  _ => null,
};
