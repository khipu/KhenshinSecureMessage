# KhenshinSecureMessage

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation (Swift Package Manager)

Add the package to your `Package.swift` dependencies:

    .package(url: "https://github.com/khipu/KhenshinSecureMessage.git", from: "1.4.1")

Then add `KhenshinSecureMessage` to your target's dependencies, or in Xcode use
**File → Add Package Dependencies…** with the same URL.

> En SPM la criptografía se provee vía `tweetnacl-swiftwrap` (módulo `TweetNacl`);
> en CocoaPods vía `KHTweetNaclSwift`. La API (`NaclBox`/`NaclSecretBox`) es idéntica
> y la compatibilidad está cubierta por los tests.

## Installation

KhenshinSecureMessage is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'KhenshinSecureMessage'
```

This pod depends on `TweetNacl` which was compiled to old version of apple's SDK, in recent XCodes version please add

```ruby
post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
            end
        end
    end
end 
```

At the end of your Podfile in order to tell the compiler to update all `IPHONEOS_DEPLOYMENT_TARGET` to 12.0 (if you need a higher iOS version, please replace it).

## Author

Khipu, developers@khipu.com

## License

KhenshinSecureMessage is available under the MIT license. See the LICENSE file for more info.
