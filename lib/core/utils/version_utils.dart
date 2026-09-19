/// Compares dotted release versions such as `v7.1.0` and `7.0.3+4`.
///
/// Invalid versions are treated as non-updates instead of throwing during the
/// non-critical startup update check.
bool isVersionNewer(String candidate, String current) {
  final candidateVersion = _ParsedVersion.tryParse(candidate);
  final currentVersion = _ParsedVersion.tryParse(current);
  if (candidateVersion == null || currentVersion == null) return false;

  final length = candidateVersion.parts.length > currentVersion.parts.length
      ? candidateVersion.parts.length
      : currentVersion.parts.length;
  for (var index = 0; index < length; index++) {
    final candidatePart = index < candidateVersion.parts.length
        ? candidateVersion.parts[index]
        : 0;
    final currentPart = index < currentVersion.parts.length
        ? currentVersion.parts[index]
        : 0;
    if (candidatePart != currentPart) return candidatePart > currentPart;
  }

  return currentVersion.isPrerelease && !candidateVersion.isPrerelease;
}

class _ParsedVersion {
  final List<int> parts;
  final bool isPrerelease;

  const _ParsedVersion(this.parts, this.isPrerelease);

  static _ParsedVersion? tryParse(String value) {
    final normalized = value.trim().replaceFirst(RegExp(r'^[vV]'), '');
    if (normalized.isEmpty) return null;

    final withoutBuild = normalized.split('+').first;
    final segments = withoutBuild.split('-');
    final numericParts = segments.first.split('.');
    final parts = <int>[];
    for (final part in numericParts) {
      final parsed = int.tryParse(part);
      if (parsed == null || parsed < 0) return null;
      parts.add(parsed);
    }
    if (parts.isEmpty) return null;

    return _ParsedVersion(parts, segments.length > 1);
  }
}
