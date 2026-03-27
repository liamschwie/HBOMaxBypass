# HBOMaxBypass

A jailbreak tweak to bypass the forced upgrade screen in the HBO Max (Max) app on older iOS versions.

## How It Works

When HBO Max launches, it fetches feature flags from `discomax.com/labs/api/v1/sessions/feature-flags/decisions`. The response contains a `force-upgrade` flag with a `maxVersion` field — any app version at or below this value is blocked with a "Get the Newest Version" screen.

HBOMaxBypass intercepts this API response and sets `maxVersion` to `0.0.0`, meaning no app version will ever trigger the force upgrade. It also spoofs `UIDevice.systemVersion` to `16.4` in case the app checks the iOS version locally.

This approach is inherently **future-proof** — even if HBO changes the `maxVersion` value on their servers, the tweak will always override it to `0.0.0`.

## Compatible Versions

HBOMaxBypass has been tested with the last app version that supports iOS 16.2. To find and install a compatible version:

```bash
brew install ipatool ideviceinstaller
ipatool auth login -e <your-apple-id>
ipatool list-versions -b com.wbd.stream
# Find a version that supports your iOS, then:
ipatool download -b com.wbd.stream --external-version-id <VERSION_ID>
ideviceinstaller install com.wbd.stream_*.ipa
```

The tweak should work with any older version of the app that can launch on your iOS version but is blocked by the force upgrade screen.

## Installation

### From a .deb (Releases)

1. Download the latest `.deb` from [Releases](../../releases)
2. Transfer to your device and install with Filza or your package manager
3. Respring

### Building from source

Requires [Theos](https://theos.dev/docs/installation).

```bash
git clone https://github.com/<your-username>/HBOMaxBypass.git
cd HBOMaxBypass
make package
```

The `.deb` will be in the `packages/` directory. The default build targets **rootless** jailbreaks (Dopamine, palera1n). For rootful jailbreaks, remove the `THEOS_PACKAGE_SCHEME = rootless` line from the Makefile.

## Technical Details

The tweak hooks two things:

1. **`UIDevice systemVersion`** — Returns `16.4` instead of the real iOS version, bypassing any local OS version checks within the app.

2. **`NSURLSession dataTaskWithRequest:completionHandler:`** — Intercepts responses from the feature flags API endpoint. When the response contains the `force-upgrade` flag, it uses a regex to replace `"maxVersion":"<any-value>"` with `"maxVersion":"0.0.0"` before the app processes it.

### What could break it

- HBO renames the `force-upgrade` key in their feature flags → **unlikely**, would break their own clients
- HBO changes the API endpoint URL away from `feature-flags` → **unlikely**, same reason
- HBO switches to certificate pinning that blocks response modification → **possible** but the tweak operates at the NSURLSession level, not as a proxy, so standard pinning wouldn't affect it

## Requirements

- Jailbroken iOS device (iOS 15.0+)
- Rootless jailbreak (Dopamine, palera1n, etc.) — or modify Makefile for rootful
- A compatible version of the HBO Max app installed via `ideviceinstaller` or the App Store

## License

This project is made available under the [GNU GPLv3](LICENSE).
