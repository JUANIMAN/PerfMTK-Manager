import 'dart:convert';
import 'dart:typed_data';

import 'package:manager/features/system/data/models/profile.dart';
import 'package:manager/features/system/data/models/system_state.dart';

/// Byte offsets of the `PerfMTKSharedTelemetry` struct published by `perfmtkd`
/// through anonymous shared memory. Must stay in sync with the daemon header.
abstract final class ShmLayout {
  static const int magic = 0x504D544B; // "PMTK"
  static const int version = 1;
  static const int structSize = 2784;

  // Header.
  static const int magicOffset = 0;
  static const int versionOffset = 4;
  static const int seqOffset = 8;
  static const int flagsOffset = 12;

  // Scalars (int32).
  static const int driversActive = 24;
  static const int displayFps = 28;
  static const int gameFps = 32;
  static const int batteryTempC = 36;
  static const int socTempMdeg = 40;
  static const int batteryCapPct = 44;
  static const int cycleCount = 48;
  static const int sohPct = 52;
  static const int chargeFullMah = 56;
  static const int chargeDesignMah = 60;
  static const int chargeCounterMah = 64;
  static const int chargeCurrentNowMa = 68;
  static const int chargeVoltageNowMv = 72;
  static const int chargePowerMw = 76;
  static const int chargeCurrentLimitMa = 80;
  static const int gentleChargeMa = 84;
  static const int batteryCareLimitPct = 88;
  static const int pinnedThreadsCount = 92;

  // Fixed-width, NUL-terminated strings: (offset, max length).
  static const (int, int) versionStr = (96, 16);
  static const (int, int) activeProfile = (112, 32);
  static const (int, int) currentApp = (144, 128);
  static const (int, int) fgEngine = (272, 48);
  static const (int, int) socName = (320, 32);
  static const (int, int) socArch = (352, 32);
  static const (int, int) gpuType = (384, 32);
  static const (int, int) cpuClusters = (416, 128);
  static const (int, int) gpuFreq = (544, 32);
  static const (int, int) dramFreq = (576, 32);
  static const (int, int) uclamp = (608, 64);
  static const (int, int) chargeMode = (672, 32);
  static const (int, int) chargeStatus = (704, 32);

  // Pinned threads table.
  static const int threadsBase = 736;
  static const int threadStride = 64;
  static const int threadsMax = 32;
  static const int threadNameOffset = 4;
  static const int threadNameLen = 28;
  static const int threadRoleOffset = 32;
  static const int threadRoleLen = 32;

  // Flag bits.
  static const int flagScreenOn = 1 << 0;
  static const int flagChargeBypass = 1 << 1;
  static const int flagBatteryCareEnabled = 1 << 2;
  static const int flagBatteryCareSuspended = 1 << 3;
  static const int flagBackgroundJailed = 1 << 4;
  static const int flagThermalEnabled = 1 << 5;
}

/// Decodes a `PerfMTKSharedTelemetry` binary snapshot into a [SystemState].
abstract final class ShmTelemetryDecoder {
  /// Returns null when the buffer is too short or the magic/version mismatch.
  static SystemState? decode(Uint8List bytes, [ByteData? view]) {
    if (bytes.length < ShmLayout.structSize) return null;
    final bd = view ?? ByteData.sublistView(bytes);

    final magic = bd.getUint32(ShmLayout.magicOffset, Endian.host);
    final structVersion = bd.getUint32(ShmLayout.versionOffset, Endian.host);
    if (magic != ShmLayout.magic || structVersion != ShmLayout.version) {
      return null;
    }

    int i32(int offset) => bd.getInt32(offset, Endian.host);
    String str((int, int) field) => _readCString(bytes, field.$1, field.$2);

    final flags = bd.getUint32(ShmLayout.flagsOffset, Endian.host);
    bool flag(int bit) => (flags & bit) != 0;

    final chargeBypass = flag(ShmLayout.flagChargeBypass);
    final socTempMdeg = i32(ShmLayout.socTempMdeg);
    final displayFps = i32(ShmLayout.displayFps);
    final gameFps = i32(ShmLayout.gameFps);
    final cycleCount = i32(ShmLayout.cycleCount);
    final sohPct = i32(ShmLayout.sohPct);
    final chargeFullMah = i32(ShmLayout.chargeFullMah);
    final chargeDesignMah = i32(ShmLayout.chargeDesignMah);
    final chargeCounterMah = i32(ShmLayout.chargeCounterMah);
    final batteryCareLimitPct = i32(ShmLayout.batteryCareLimitPct);
    final chargeMode = str(ShmLayout.chargeMode);
    final chargeStatus = str(ShmLayout.chargeStatus);

    return SystemState(
      currentProfile: ProfileType.fromString(str(ShmLayout.activeProfile)),
      thermalState: flag(ShmLayout.flagThermalEnabled)
          ? ThermalState.enabled
          : ThermalState.disabled,
      version: str(ShmLayout.versionStr),
      currentApp: str(ShmLayout.currentApp),
      screenOn: flag(ShmLayout.flagScreenOn),
      fgEngine: str(ShmLayout.fgEngine),
      socName: str(ShmLayout.socName),
      socArch: str(ShmLayout.socArch),
      gpuType: str(ShmLayout.gpuType),
      cpuClusters: str(ShmLayout.cpuClusters),
      gpuFreq: str(ShmLayout.gpuFreq),
      dramFreq: str(ShmLayout.dramFreq),
      chargeBypass: chargeBypass,
      chargeMode: chargeMode.isNotEmpty
          ? chargeMode
          : (chargeBypass ? 'bypass' : 'normal'),
      chargeStatus: chargeStatus.isNotEmpty ? chargeStatus : 'Discharging',
      chargeCurrentNowMa: i32(ShmLayout.chargeCurrentNowMa),
      chargeVoltageNowMv: i32(ShmLayout.chargeVoltageNowMv),
      chargePowerW: i32(ShmLayout.chargePowerMw) / 1000.0,
      chargeCurrentLimitMa: i32(ShmLayout.chargeCurrentLimitMa),
      gentleChargeMa: i32(ShmLayout.gentleChargeMa),
      batteryTempC: i32(ShmLayout.batteryTempC),
      socTempC: socTempMdeg > 0 ? socTempMdeg / 1000.0 : null,
      uclamp: str(ShmLayout.uclamp),
      driversActive: i32(ShmLayout.driversActive),
      displayFps: displayFps > 0 ? displayFps : null,
      gameFps: gameFps > 0 ? gameFps : null,
      batteryCapacityPct: i32(ShmLayout.batteryCapPct),
      batteryCycleCount: cycleCount >= 0 ? cycleCount : null,
      batterySohPct: sohPct > 0 ? sohPct : null,
      chargeFullMah: chargeFullMah > 0 ? chargeFullMah : null,
      chargeDesignMah: chargeDesignMah > 0 ? chargeDesignMah : null,
      chargeCounterMah: chargeCounterMah > 0 ? chargeCounterMah : null,
      batteryCareEnabled: flag(ShmLayout.flagBatteryCareEnabled),
      batteryCareLimitPct: batteryCareLimitPct > 0 ? batteryCareLimitPct : 80,
      batteryCareSuspended: flag(ShmLayout.flagBatteryCareSuspended),
      backgroundJailed: flag(ShmLayout.flagBackgroundJailed),
      pinnedThreads: _readThreads(bytes, bd),
    );
  }

  static List<Map<String, dynamic>> _readThreads(Uint8List bytes, ByteData bd) {
    final count = bd
        .getInt32(ShmLayout.pinnedThreadsCount, Endian.host)
        .clamp(0, ShmLayout.threadsMax);
    final threads = <Map<String, dynamic>>[];
    for (var i = 0; i < count; i++) {
      final base = ShmLayout.threadsBase + (i * ShmLayout.threadStride);
      final tid = bd.getInt32(base, Endian.host);
      if (tid <= 0) continue;
      threads.add({
        'tid': tid,
        'name': _readCString(
          bytes,
          base + ShmLayout.threadNameOffset,
          ShmLayout.threadNameLen,
        ),
        'role': _readCString(
          bytes,
          base + ShmLayout.threadRoleOffset,
          ShmLayout.threadRoleLen,
        ),
      });
    }
    return threads;
  }

  static String _readCString(Uint8List bytes, int offset, int maxLen) {
    var end = offset;
    final limit = offset + maxLen;
    while (end < limit && end < bytes.length && bytes[end] != 0) {
      end++;
    }
    if (end <= offset) return '';
    return utf8.decode(
      Uint8List.sublistView(bytes, offset, end),
      allowMalformed: true,
    );
  }
}
