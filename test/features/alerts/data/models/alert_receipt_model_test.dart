import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/alerts/data/models/alert_receipt_hive.dart';
import 'package:tabibu/features/alerts/data/models/alert_receipt_model.dart';

void main() {
  group('AlertReceiptModel', () {
    test('fromJson round-trips through toJson', () {
      final json = {
        'alertUid': 'alert-1',
        'readAt': '2026-11-01T12:00:00.000Z',
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
      };
      expect(AlertReceiptModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = AlertReceiptModel.fromJson({});
      expect(model.alertUid, '');
      expect(model.readAt, '');
      expect(model.synced, isTrue);
    });

    test('toJson never contains synced', () {
      expect(
        AlertReceiptModel.fromJson({
          'alertUid': 'a',
        }).toJson().containsKey('synced'),
        isFalse,
      );
    });

    test('isRead on both sides', () {
      expect(const AlertReceiptModel().isRead, isFalse);
      expect(
        const AlertReceiptModel(readAt: '2026-11-01T12:00:00.000Z').isRead,
        isTrue,
      );
    });
  });

  group('AlertReceiptHive', () {
    test('fromModel maps and round-trips unsynced', () {
      const model = AlertReceiptModel(
        alertUid: 'alert-1',
        readAt: '2026-11-01T12:00:00.000Z',
        synced: false,
      );
      expect(AlertReceiptHive.fromModel(model).toModel(), model);
    });
  });
}
