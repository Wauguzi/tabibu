import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/auth/presentation/widgets/field_errors.dart';
import 'package:tabibu/l10n/l10n.dart';

void main() {
  group('fieldFor', () {
    test('maps each field error to its field', () {
      expect(fieldFor(AppError.invalidTitle), SignUpField.title);
      expect(fieldFor(AppError.invalidPicture), SignUpField.picture);
      expect(fieldFor(AppError.invalidEmail), SignUpField.email);
      expect(fieldFor(AppError.emailAlreadyInUse), SignUpField.email);
      expect(fieldFor(AppError.weakPassword), SignUpField.password);
      expect(fieldFor(AppError.invalidName), SignUpField.name);
      expect(fieldFor(AppError.invalidSex), SignUpField.sex);
      expect(fieldFor(AppError.invalidDateOfBirth), SignUpField.dateOfBirth);
      expect(fieldFor(AppError.invalidPhone), SignUpField.phone);
      expect(fieldFor(AppError.invalidCounty), SignUpField.county);
      expect(fieldFor(AppError.invalidSubCounty), SignUpField.subCounty);
    });

    test('returns null for errors with no field', () {
      expect(fieldFor(AppError.noInternet), isNull);
      expect(fieldFor(AppError.unknown), isNull);
    });
  });

  group('errorAfterChange', () {
    test("clears the changed field's error", () {
      expect(errorAfterChange(.invalidEmail, .email), isNull);
    });

    test("keeps another field's error", () {
      expect(
        errorAfterChange(.emailAlreadyInUse, .password),
        AppError.emailAlreadyInUse,
      );
    });

    test('clears a notice error', () {
      expect(errorAfterChange(.noInternet, .email), isNull);
    });

    test('leaves no error as none', () {
      expect(errorAfterChange(null, .name), isNull);
    });
  });

  group('fieldErrorText', () {
    test('names the problem in English', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      expect(fieldErrorText(AppError.invalidTitle, l10n), 'Choose your title');
      expect(
        fieldErrorText(AppError.invalidPicture, l10n),
        'Add a photo of yourself',
      );
      expect(
        fieldErrorText(AppError.invalidEmail, l10n),
        "That doesn't look like an email address",
      );
      expect(
        fieldErrorText(AppError.emailAlreadyInUse, l10n),
        'An account already uses this email. Sign in instead.',
      );
      expect(
        fieldErrorText(AppError.weakPassword, l10n),
        'Use at least 8 characters, a number and a symbol',
      );
      expect(fieldErrorText(AppError.invalidName, l10n), 'Enter your name');
      expect(fieldErrorText(AppError.invalidSex, l10n), 'Choose one');
      expect(
        fieldErrorText(AppError.invalidDateOfBirth, l10n),
        'Enter your date of birth',
      );
      expect(
        fieldErrorText(AppError.invalidPhone, l10n),
        'Enter a Kenyan mobile number, like 712 345 678',
      );
      expect(
        fieldErrorText(AppError.invalidCounty, l10n),
        'Choose your county',
      );
      expect(
        fieldErrorText(AppError.invalidSubCounty, l10n),
        'Choose your area',
      );
    });

    test('is translated to Kiswahili', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('sw'));

      expect(fieldErrorText(AppError.invalidTitle, l10n), 'Chagua cheo chako');
      expect(fieldErrorText(AppError.invalidPicture, l10n), 'Weka picha yako');
      expect(
        fieldErrorText(AppError.invalidEmail, l10n),
        'Hiyo haionekani kama anwani ya barua pepe',
      );
      expect(
        fieldErrorText(AppError.emailAlreadyInUse, l10n),
        'Tayari kuna akaunti inayotumia barua pepe hii. Ingia badala yake.',
      );
      expect(
        fieldErrorText(AppError.weakPassword, l10n),
        'Tumia angalau herufi 8, namba na alama',
      );
      expect(fieldErrorText(AppError.invalidName, l10n), 'Andika jina lako');
      expect(fieldErrorText(AppError.invalidSex, l10n), 'Chagua moja');
      expect(
        fieldErrorText(AppError.invalidDateOfBirth, l10n),
        'Andika tarehe yako ya kuzaliwa',
      );
      expect(
        fieldErrorText(AppError.invalidPhone, l10n),
        'Andika namba ya simu ya Kenya, kama 712 345 678',
      );
      expect(
        fieldErrorText(AppError.invalidCounty, l10n),
        'Chagua kaunti yako',
      );
      expect(
        fieldErrorText(AppError.invalidSubCounty, l10n),
        'Chagua eneo lako',
      );
    });
  });
}
