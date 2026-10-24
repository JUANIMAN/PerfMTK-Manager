import 'package:manager/features/backup/data/backup_entry.dart';

/// Parses `ls -l` output of the backups directory into [BackupEntry] items.
abstract final class BackupListParser {
  static final RegExp _fileName = RegExp(
    r'profiles_(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2})\.tar\.gz',
  );

  /// Entries are sorted newest first and numbered from 1.
  /// A size that cannot be read is reported as 0 (rendered as "0 B").
  static List<BackupEntry> parseLsOutput(String lsOutput) {
    final parsed = <BackupEntry>[];
    for (final line in lsOutput.split('\n')) {
      final match = _fileName.firstMatch(line);
      if (match == null) continue;

      final parts = line.trim().split(RegExp(r'\s+'));
      final size = parts.length >= 5 ? int.tryParse(parts[4]) ?? 0 : 0;
      parsed.add(
        BackupEntry(
          index: 0,
          filename: match.group(0)!,
          date:
              '${match.group(1)}-${match.group(2)}-${match.group(3)} '
              '${match.group(4)}:${match.group(5)}:${match.group(6)}',
          sizeBytes: size,
        ),
      );
    }

    parsed.sort((a, b) => b.filename.compareTo(a.filename));
    return [
      for (var i = 0; i < parsed.length; i++)
        BackupEntry(
          index: i + 1,
          filename: parsed[i].filename,
          date: parsed[i].date,
          sizeBytes: parsed[i].sizeBytes,
        ),
    ];
  }
}
