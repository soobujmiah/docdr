// Determinism suite for date resolution (DOC-08).
//
// Document generation must be reproducible: two runs over the same record
// must produce byte-identical output. That is only possible if the instant
// used to fill empty date fields is injectable rather than read directly from
// the system clock at the point of use.

import 'package:docdr/core/models/custom_template.dart';
import 'package:docdr/core/services/clock.dart';
import 'package:test/test.dart';

void main() {
  final fixed = DateTime(2026, 8, 29);

  DocDrElement dateElement() => DocDrElement.create(DocDrElementType.date, 1);

  group('injected time', () {
    test('formats an empty date as dd/MM/yyyy', () {
      expect(dateElement().resolveValue(const <String, String>{}, now: fixed),
          '29/08/2026');
    });

    test('pads single-digit day and month', () {
      final early = DateTime(2026, 1, 2);
      expect(
        dateElement().resolveValue(const <String, String>{}, now: early),
        '02/01/2026',
      );
    });

    test('prefers the supplied record value over the clock', () {
      expect(
        dateElement().resolveValue(
          const <String, String>{'date_1': '15/03/2025'},
          now: fixed,
        ),
        '15/03/2025',
      );
    });

    test('is reproducible across repeated calls', () {
      final element = dateElement();
      final first = element.resolveValue(const <String, String>{}, now: fixed);
      final second = element.resolveValue(const <String, String>{}, now: fixed);
      expect(first, second);
    });
  });

  group('default clock', () {
    test('falls back to docDrClock when no instant is supplied', () {
      final previous = docDrClock;
      addTearDown(() => docDrClock = previous);

      docDrClock = FixedDocumentClock(DateTime(2020, 12, 25));
      expect(dateElement().resolveValue(const <String, String>{}), '25/12/2020');
    });

    test('FixedDocumentClock always returns the same instant', () {
      final clock = FixedDocumentClock(fixed);
      expect(clock.now(), clock.now());
      expect(clock.now(), fixed);
    });

    test('SystemDocumentClock tracks real time', () {
      const clock = SystemDocumentClock();
      final before = DateTime.now();
      final reading = clock.now();
      expect(reading.isBefore(before.add(const Duration(seconds: 5))), isTrue);
      expect(reading.isAfter(before.subtract(const Duration(seconds: 5))), isTrue);
    });

    test('docDrNow reads the configured clock', () {
      final previous = docDrClock;
      addTearDown(() => docDrClock = previous);
      docDrClock = FixedDocumentClock(fixed);
      expect(docDrNow(), fixed);
    });
  });

  group('batch determinism', () {
    test('serial and date resolution are stable within a batch', () {
      final serial = DocDrElement.create(DocDrElementType.serial, 1)
        ..serialStart = 1
        ..serialDigits = 5;
      final date = dateElement();

      final batch = <Map<String, String>>[];
      for (var i = 0; i < 5; i++) {
        batch.add(<String, String>{
          'serial_1': serial.resolveValue(
            const <String, String>{},
            batchIndex: i,
          ),
          'date_1': date.resolveValue(const <String, String>{}, now: fixed),
        });
      }

      expect(batch.first['serial_1'], 'SL- 00001');
      expect(batch.last['serial_1'], 'SL- 00005');
      expect(batch.map((r) => r['date_1']).toSet(), <String>{'29/08/2026'});
    });
  });
}
