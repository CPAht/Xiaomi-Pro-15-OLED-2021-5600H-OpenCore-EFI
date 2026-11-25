# EFI — 小米笔记本 Pro 15 OLED 2021 · Ryzen 5 5600H · macOS Sequoia

OpenCore boot EFI for the **Xiaomi Notebook Pro 15 OLED 2021** (TM2107 / Timi A35S), AMD Ryzen 5 5600H, Renoir/Zen3, Radeon Renoir `0x1638`, 3456×2160 OLED.

> **⚠️ Disclaimer:** Reference EFI only. SMBIOS serial number, MLB, System UUID and ROM/MAC have been **removed (blank / zeroed)**. Generate your own valid SMBIOS for MacBookPro16,2 before booting; do not reuse any serial/UUID/ROM from this repo.

## Hardware

| Component | Detail |
|---|---|
| Laptop | 小米笔记本 Pro 15 OLED 2021, TM2107 / Timi A35S |
| CPU | AMD Ryzen 5 5600H (Renoir, Zen3, 6C/12T) |
| iGPU | AMD Radeon Renoir Graphics, device `0x1638`, DCN 2.1, VRAM 2GB, Metal 3 |
| Panel | eDP OLED 3456×2160@60, 10 bpc |
| RAM | 16GB |
| Storage | NVMe (IM N4PA 1TB) |
| Wi‑Fi / BT | Intel AX210 (Wi‑Fi 6E) + Intel Bluetooth |
| SMBIOS | MacBookPro16,2 (spoofed; serials blank) |
| Tested OS | macOS 15.8.3 (Sequoia, build 24H241) |

## Hardware → Feature → Driver mapping

| Hardware | Working feature | Kext / SSDT / config |
|---|---|---|
| **CPU** R5 5600H (Renoir) | CPU power management, SMC temp/freq, `plugin-type=1` | SMCProcessorAMD 1.0.4 · SSDT-PLUG-ALT · X86PlatformPlugin |
| CPU | AMD CPU name spoof, core/topology patches, MCE reporter off | RestrictEvents 1.1.7 · algrey/XLNC CPUID & commpage patches · AppleMCEReporterDisabler |
| **iGPU** Radeon Renoir `0x1638` | Graphics acceleration, Metal 3, internal framebuffer | NootedRed 1.3.1 · Lilu 1.7.3 · FeatureUnlock 1.1.9 |
| iGPU | Internal panel EDID override | DeviceProperties `AAPL00,override-no-connect` on `PciRoot(0x1)/Pci(0x8,0x1)/Pci(0x0,0x0)` |
| **OLED panel** | Brightness slider, AUX nits backlight path | NootedRed AUX nits · SSDT-PNLF · boot-arg `-NRedOLED` |
| Brightness hotkeys | Fn brightness keys | BrightnessKeys 1.0.4 · SSDT-PNLF |
| **Ambient light sensor** AMD SFH `1022:15e4` | ALS / auto-brightness input | AMDSFHLightSensor 1.0.0 · AMDSFHALSPlugin 1.0.0 · SSDT-ALS0 |
| **Audio** Family 17h HD Audio | Speakers, mic, headphone jack | AppleALC 1.9.9 · `layout-id = 13` (`0x0d000000`) on `PciRoot(0x1)/Pci(0x8,0x1)/Pci(0x0,0x6)` |
| **Wi‑Fi** Intel AX210 | Wireless network (itlwm) | AirportItlwm-Sequoia 2.4.0 (Sequoia branch, macOS 15) |
| **Bluetooth** Intel AX210 | Bluetooth mice/keyboards/audio | IntelBluetoothFirmware 2.5.3 · IntelBTPatcher 2.5.3 · BlueToolFixup 2.7.6 |
| **Keyboard** PS/2 | Built-in keyboard, Fn keys | VoodooPS2Controller 2.3.8 (`VoodooPS2Keyboard`) |
| **Touchpad** I2C | Pointer, gestures, trackpad buttons | VoodooI2C 2.9.1 · VoodooGPIO 1.1 · VoodooI2CHID 1.0 · VoodooInput 1.1.7 · `VoodooPS2Trackpad` / `VoodooPS2Mouse` fallback |
| **Battery** EC | Capacity, charging state, SMC battery keys | VirtualSMC 1.3.9 · SMCBatteryManager 1.3.9 (built-in `SSDT-BATC.dsl`) |
| **USB** controller | Port mapping, USB power properties | USBMap 1.1 (USBToolBox) · SSDT-USBX |
| **Embedded controller / SMBus** | EC and SBUS power resources | SSDT-EC · SSDT-MCHC-SBUS |
| **Sleep / wake** | Wake-source whitelist (lid open / power button only) | SSDT-GPRW (+`.dsl`) · GPRW→XPRW rename · SSDT-XOSI |
| SMC integrity | Forged SMC identifier | ForgedInvariant 1.6.0 |
| Boot layer | OpenCore load, HFS+ support, NVRAM reset entry, shell tool | OpenCore.efi · OpenRuntime.efi · HfsPlus.efi · ResetNvramEntry.efi · OpenShell.efi |

## Boot-args

```
-FIPeriodic itlwm_he=1 -btlfxallowanyaddr -btlfxboardid -NRedDPDelay -NRedOLED -NRedDarkWakeFix darkwake=0
```

## Kext list

| Kext | Bundle | Version |
|---|---|---|
| Lilu | as.vit9696.Lilu | 1.7.3 |
| VirtualSMC | as.vit9696.VirtualSMC | 1.3.9 |
| SMCBatteryManager | ru.usrsse2.SMCBatteryManager | 1.3.9 |
| SMCProcessorAMD | as.lorys89.SMCProcessorAMD | 1.0.4 |
| NootedRed | org.ChefKiss.NootedRed | 1.3.1 |
| AppleALC | as.vit9696.AppleALC | 1.9.9 |
| FeatureUnlock | com.khronokernel.FeatureUnlock | 1.1.9 |
| RestrictEvents | as.vit9696.RestrictEvents | 1.1.7 |
| BrightnessKeys | as.acidanthera.BrightnessKeys | — |
| BlueToolFixup | as.acidanthera.BlueToolFixup | 2.7.6 |
| IntelBTPatcher | com.zxystd.IntelBTPatcher | 2.5.3 |
| IntelBluetoothFirmware | com.zxystd.IntelBluetoothFirmware | 2.5.3 |
| ForgedInvariant | org.ChefKiss.ForgedInvariant | 1.6.0 |
| AirportItlwm (Sequoia) | com.zxystd.AirportItlwm | 2.4.0 |
| VoodooGPIO / VoodooI2C / VoodooI2CHID / VoodooInput | com.alexandred.* | 2.9.1 / 1.0 |
| VoodooPS2Controller | as.acidanthera.voodoo.driver.PS2Controller | 2.3.8 |
| AMDSFHALSPlugin / AMDSFHLightSensor | com.local.* | 1.0.0 |
| USBMap | com.dhinakg.USBToolBox.map | 1.1 |
| AppleMCEReporterDisabler | org.xlnc.disabler.MCEReporter | — |

> No WhateverGreen, no NVMeFix, no HibernationFixup in this setup.

## ACPI SSDTs

`SSDT-ALS0` (ALS), `SSDT-EC` (embedded controller), `SSDT-GPRW` (+`.dsl`, wake-source GPRW/XPRW stub), `SSDT-MCHC-SBUS`, `SSDT-PLUG-ALT` (CPU plugin), `SSDT-PNLF` (+`.dsl`, backlight), `SSDT-USBX` (USB power), `SSDT-XOSI` (`_OSI` override).

## Drivers / Tools

- Drivers: `HfsPlus.efi`, `OpenRuntime.efi`, `ResetNvramEntry.efi`
- Tools: `OpenShell.efi`

## Status & known notes

- OLED brightness works through the AUX nits path; `-NRedOLED` forces `supportsAUX` on.
- S3/AC sleep wake-on-lid verified once after a long AC sleep on 15.8.3; long-inactive GPU black-screen recovery on Renoir remains the main risk and is not fully resolved upstream.
- `NRedDarkWakeFix` is an out-of-tree fork module bundled in this 1.3.1 build (wake liveness probe + retry re-power); it is not part of the upstream master.
- Audio, Wi‑Fi (itlwm), Bluetooth, keyboard, I2C touchpad, light sensor and battery are wired up.

## Before you use this

1. Generate your own SMBIOS (SystemSerialNumber, MLB, SystemUUID, ROM) for MacBookPro16,2 with a valid checker and fill `PlatformInfo → Generic`.
2. Review `config.plist` — PCI layout, USB map, audio layout-id and kext order are machine-specific.
3. Do not reuse any serial/UUID/ROM from this repository.
