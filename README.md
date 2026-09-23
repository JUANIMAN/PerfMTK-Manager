# PerfMTK Manager

**The official, modern companion application for the PerfMTK ecosystem on MediaTek Dimensity and Helio devices.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&style=flat-square)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Riverpod%203-blue?style=flat-square)](https://riverpod.dev)
[![Current Release](https://img.shields.io/badge/release-v8.1.0-success?style=flat-square)](https://github.com/JUANIMAN/PerfMTK-Manager/releases/latest)
[![GitHub Downloads](https://img.shields.io/github/downloads/JUANIMAN/PerfMTK-Manager/total?style=flat-square)](https://github.com/JUANIMAN/PerfMTK-Manager/releases)

---

## Overview

PerfMTK Manager provides an intuitive, high-performance visual interface to monitor, customize, and orchestrate the native PerfMTK daemon (`perfmtkd`). Interacting over low-latency abstract UNIX sockets (`@perfmtkd_ctrl`), the application delivers sub-millisecond telemetry updates, granular hardware tuning, and automated per-app profile management.

---

## Features

### 1. Bento Telemetry Console (Live Silicon Status)
* **CPU Clusters**: Real-time clock frequencies and utilization percentages for Little, Mid, and Prime CPU clusters.
* **Graphics & Memory**: Live Mali GPU clock speeds and LPDDR5X DRAM bus frequencies (up to 8533 MHz).
* **Thermal State & Power**: Real-time SoC silicon temperature, battery cell temperature, and Smart Fast Charge Bypass active indicators.
* **Global Profile Switcher**: Instant switching between **Performance**, **Balanced**, **Power Save**, and **Power Save+** profiles.

### 2. Real-Time Thermal Analytics
* **Continuous Temperature Graphs**: 60-second rolling charts displaying SoC and battery temperature curves simultaneously.
* **Thermal Metrics**: Live calculations of minimum, maximum, and average thermal values.
* **Predictive Thermal Guardian**: Direct toggle and parameter tuning to eliminate hardware sawtooth frame-drop throttling during extended gaming sessions.
* **OEM Thermal Throttling Control**: Fast toggling of vendor thermal services with safety guards.

### 3. Visual Profile Editor
Granular, intuitive sliders and dropdown controls for all 10 native HAL subsystems:
* **CPU Tuning**: Independent min/max frequency sliders, governors (`schedutil`, `performance`, `powersave`), and active core toggles per cluster.
* **GPU & Memory**: Target GPU clocks and DVFSRC DRAM bus frequencies.
* **Storage (UFS)**: UFS storage governor and clock gating parameters.
* **MediaTek Engine Controls**:
  * **FPSGO**: Frame-rate stabilizer modes (`Off`, `On`, `Free`) and Top-App boosting.
  * **GBE**: Game Boost Engine enabling and thermal headroom allocation.
  * **uclamp**: Top-App minimum and maximum task clamping values.
* **Thermal & Charging**:
  * Smart Fast Charge Bypass with emergency battery safety cutoff guard.
  * FPS Thermal Cap unlock toggle.
* **Touch & Digitizer Booster**:
  * Hardware Gaming Mode toggle (480Hz sample rate / 2160Hz instant response via `/dev/xiaomi-touch`).
  * Host-side `THP Smooth` gesture jitter filter.

### 4. Per-App Profiles & Game Directives
* **Auto-Detection**: Scans installed user and system applications with cached high-resolution icons.
* **Granular Filters**: Categorize by *All Apps*, *Configured*, or *Not Configured*.
* **Game Rules**: Assign dedicated profiles, thermal bypass, and touch acceleration directives (e.g., `;thermal=off;touch=game`) applied instantly upon app launch.
* **Global Daemon Policies**: Configurable Screen-Off profile and asynchronous app switch delay (debounce).

### 5. Android Quick Settings Tiles
* **`ProfileTileService`**: Cycle through energy profiles directly from the Android notification shade.
* **`ChargeBypassTileService`**: Toggle Smart Fast Charge Bypass with a single tap while plugged in.

### 6. Design & Customization
* **Glassmorphic Navigation**: Floating bottom navigation bar with fluid screen transitions.
* **Dynamic Theming**: Full Material 3 support with dark and light palettes.
* **Bilingual Localization**: Complete native Spanish and English translations.

---

## Requirements

* **Device**: MediaTek Dimensity or Helio processor with a Mali GPU.
* **Android Version**: Android 9.0 (Pie) through Android 15 / 16.
* **Root Solution**: Magisk (v27+), KernelSU, or APatch with Root permissions granted.
* **Underlying Module**: PerfMTK Magisk Module `v16.2` installed.

---

## Building from Source

Prerequisites:
* Flutter SDK (3.24+ recommended)
* Android SDK (API 34+)
* Java 17+

```bash
# Clone the repository
git clone https://github.com/JUANIMAN/PerfMTK-Manager.git
cd PerfMTK-Manager

# Fetch Flutter dependencies
flutter pub get

# Run test suite
flutter test

# Build release APK
flutter build apk --release
```

The compiled release APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## License

This application is free and open-source, licensed under the [MIT License](LICENSE).
