import 'package:installed_apps/app_info.dart';
import 'package:manager/data/models/profile.dart';

class AppProfile {
  final AppInfo appInfo;
  final ProfileType? assignedProfile;

  const AppProfile({
    required this.appInfo,
    this.assignedProfile,
  });

  AppProfile copyWith({
    AppInfo? appInfo,
    ProfileType? assignedProfile,
    bool clearProfile = false,
  }) {
    return AppProfile(
      appInfo: appInfo ?? this.appInfo,
      assignedProfile: clearProfile ? null : (assignedProfile ?? this.assignedProfile),
    );
  }

  bool get isConfigured => assignedProfile != null;
}
