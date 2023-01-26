# koko-iOS
iOS client for koko

## Environments

- [cocoapods](https://guides.cocoapods.org/using/getting-started.html)
- [fastlane](https://docs.fastlane.tools/)

## Build

```
bundle exec pod install
# if you use Apple Silicon (M1), it might need `arch -x86_64` before `pod install`

open kokonats.xcworkspace
# => then run
```

## Upload to TestFlight

See: [./fastlane/README.md](./fastlane/README.md)

```
# Option: Set your apple id into the env for use with fastlane
export FASTLANE_USER=xxxx@example.com
# Option: Generate password for koko-ios from https://support.apple.com/HT204397
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=xxxxx

# build and upload
bundle exec fastlane ios beta
# Just wait for completion, maybe 10 or more minutes.
# Then, you must commit and push because the same build number cannot be used.
```

TODO: use App Store Connect API Key after being provided it by srl
