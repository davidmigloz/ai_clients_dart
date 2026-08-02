@TestOn('vm')
library;

import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('DatasetRecordSource enum', () {
    test('maps all values both ways', () {
      expect(
        DatasetRecordSource.fromJson('EXPLORER'),
        DatasetRecordSource.explorer,
      );
      expect(
        DatasetRecordSource.fromJson('UPLOADED_FILE'),
        DatasetRecordSource.uploadedFile,
      );
      expect(
        DatasetRecordSource.fromJson('DIRECT_INPUT'),
        DatasetRecordSource.directInput,
      );
      expect(
        DatasetRecordSource.fromJson('PLAYGROUND'),
        DatasetRecordSource.playground,
      );

      expect(DatasetRecordSource.explorer.toJson(), 'EXPLORER');
      expect(DatasetRecordSource.uploadedFile.toJson(), 'UPLOADED_FILE');
      expect(DatasetRecordSource.directInput.toJson(), 'DIRECT_INPUT');
      expect(DatasetRecordSource.playground.toJson(), 'PLAYGROUND');
    });

    test('falls back to unknown for null or unrecognized values', () {
      expect(DatasetRecordSource.fromJson(null), DatasetRecordSource.unknown);
      expect(
        DatasetRecordSource.fromJson('SOMETHING_NEW'),
        DatasetRecordSource.unknown,
      );
    });
  });
}
