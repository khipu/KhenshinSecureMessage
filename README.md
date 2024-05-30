# KhenshinSecureMessage

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

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
