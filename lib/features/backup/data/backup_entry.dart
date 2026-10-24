/// Represents a timestamped archive snapshot of PerfMTK profiles.
class BackupEntry {
  final int index;
  final String filename;
  final String date;
  final int sizeBytes;

  const BackupEntry({
    required this.index,
    required this.filename,
    required this.date,
    required this.sizeBytes,
  });

  factory BackupEntry.fromJson(Map<String, dynamic> json) {
    return BackupEntry(
      index: (json['index'] as num?)?.toInt() ?? 1,
      filename: json['filename'] as String? ?? '',
      date: json['date'] as String? ?? '',
      sizeBytes: (json['size_bytes'] as num?)?.toInt() ?? 0,
    );
  }

  String get formattedSize {
    if (sizeBytes <= 0) return '0 B';
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
