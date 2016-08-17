# TradeItIosTicketSDK

## Cocoapods

Follow the [Cocoapods: Getting started guide](https://guides.cocoapods.org/using/getting-started.html) and [Cocoapods: Using Cocoapods guide](https://guides.cocoapods.org/using/using-cocoapods.html) if you've never used Cocoapods before.

Inside your `Podfile` you need to add the TradeIt spec repo as a source:

```ruby
source 'https://github.com/tradingticket/SpecRepo'
```

Under your project target add our Ticket SDK pod as a dependency:

```ruby
pod 'TradeItIosTicketSDK', '0.1.1'
```

This is a base example of what it should look like:

```ruby
source 'https://github.com/tradingticket/SpecRepo'

target 'YourProjectTargetName' do
  use_frameworks!
  pod 'TradeItIosTicketSDK', '0.1.1'
end
```

Then run:

```
pod install
```

The Ticket SDK and Ad SDK should be installed for you.

## Deprecated framework build notes
NOTE: To build select the framework target, and iOS Device and build (it will build for both iOS and Simulators)

Also, the frameworks are copied to this location:  ${HOME}/Code/TradeIt/TradeItIosTicketSDKLib/  if that's not where your code is, your missing out on life :) you can go into the Framework Build Phases and modify the last couple lines in the MultiPlatform Build Script

XCode7 - As of XCode7/iOS9 the submission process has changed, until we get a build script you'll need to manually edit the Info.plist file inside the generated .bundle  Open the file and remove the CFSupportedPlatforms and ExecutableFile lines.
