import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Sign-up fields that show their error under the field instead of the
/// notice above the form.
enum SignUpField {
  title,
  picture,
  email,
  password,
  name,
  sex,
  dateOfBirth,
  phone,
  county,
  subCounty,
}

/// The field an error belongs to, or null when it stays in the notice.
SignUpField? fieldFor(AppError error) => switch (error) {
  .invalidTitle => .title,
  .invalidPicture => .picture,
  .invalidEmail || .emailAlreadyInUse => .email,
  .weakPassword => .password,
  .invalidName => .name,
  .invalidSex => .sex,
  .invalidDateOfBirth => .dateOfBirth,
  .invalidPhone => .phone,
  .invalidCounty => .county,
  .invalidSubCounty => .subCounty,
  _ => null,
};

/// The short message naming the problem at its field. Errors with no
/// field keep their notice text.
String fieldErrorText(AppError error, AppLocalizations l10n) => switch (error) {
  .invalidTitle => l10n.fieldErrorTitle,
  .invalidPicture => l10n.fieldErrorPicture,
  .invalidEmail => l10n.fieldErrorEmailInvalid,
  .emailAlreadyInUse => l10n.fieldErrorEmailInUse,
  .weakPassword => l10n.fieldErrorPasswordWeak,
  .invalidName => l10n.fieldErrorName,
  .invalidSex => l10n.fieldErrorSex,
  .invalidDateOfBirth => l10n.fieldErrorDateOfBirth,
  .invalidPhone => l10n.fieldErrorPhone,
  .invalidCounty => l10n.fieldErrorCounty,
  .invalidSubCounty => l10n.fieldErrorSubCounty,
  _ => error.description(l10n),
};

/// [error] once [field] changes: that field's error and any notice clear,
/// another field's error stays.
AppError? errorAfterChange(AppError? error, SignUpField field) {
  final owner = error == null ? null : fieldFor(error);
  return owner == null || owner == field ? null : error;
}
