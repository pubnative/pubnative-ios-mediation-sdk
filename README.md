![ScreenShot](PNLogo.png)

[![CircleCI](https://circleci.com/gh/pubnative/pubnative-ios-mediation-sdk.svg?style=shield)](https://circleci.com/gh/pubnative/pubnative-ios-mediation-sdk) [![Coverage Status](https://coveralls.io/repos/github/pubnative/pubnative-ios-mediation-sdk/badge.svg)](https://coveralls.io/github/pubnative/pubnative-ios-mediation-sdk) ![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)

PubNative is an API-based publisher platform dedicated to native advertising which does not require the integration of an Library.

Through PubNative, publishers can request over 20 parameters to enrich their ads and thereby create any number of combinations for unique and truly native ad units.

# pubnative-ios-mediation-sdk

pubnative-ios-mediation-sdk is an Open Source client mediation layer for integrating multiple ad networks inside your app with remote control using the PubNative Dashboard.

## Contents

* [Requirements](#requirements)
* [Install](#install)
    * [Manually](#install_manual)
* [Usage](#usage)
    * [Request ads](#usage_request)
    * [Track ad](#usage_track_ad)
    * [Ad model delegate](#usage_ad_delegate)
    * [Targeting ad](#usage_targeting_ad)
* [Third party networks](#networks)
* [Misc](#misc)
    * [License](#misc_license)
    * [Contributing](#misc_contributing)

<a name="requirements"></a>
# Requirements

* iOS 7.0+
* An App Token provided in PubNative Dashboard.
* A Placement Name configured in the PubNative Dashboard

<a name="install"></a>
# Install

<a name="install_manual"></a>
### Manual
Clone the repository and drag'n'drop the `mediation/mediation` folder into your app (be sure to check the "Copy items into destination group's folder" option).

<a name="usage"></a>
# Usage

PubNative mediation is a lean yet complete project that allow you request ads from different networks with remote control from the PubNative Dashboard.

Basic integration steps are:

1. [Request ads](#usage_request): Using `PubnativeNetworkRequest`
2. [Track ad](#usage_track_ad): Using the returned `PubnativeAdModel`

Optional integration steps:

1. [Ad model delegate](#usage_ad_delegate): Using `PubnativeAdModelDelegate`
2. [Targeting ad](#usage_targeting_ad): Using `PubnativeAdTargetingModel`

<a name="usage_request"></a>
### Request Ads

In order to request an Ad you need to create a request, fill it with your data and start it providing a callback for the ad response.

You can set up several data before starting the request by using the helper `PubnativeNetworkRequest` methods. This is an optional usage but in the long term will seriously improve your ad placement behaviour.

Here is a sample on how to use It.

For Swift:
```swift
let request = PubnativeNetworkRequest()
request.startWithAppToken("<APP_TOKEN>", "<PLACEMENT_NAME>", delegate: self)
```

For Objective-C:
```objective-c
PubnativeNetworkRequest *request = [[PubnativeNetworkRequest alloc] init]
[request startWithAppToken:"<APP_TOKEN>" placementName:"<PLACEMENT_NAME>" delegate: self]
```

<a name="usage_track_ad"></a>
### Track ad

For confirming impressions of the ad and handling clicks, the `PubnativeadModel` has methods to automatically track the ad view items for confirming the impression, and handling to open the offer when the user interacts, you just need to specify the view that contains the ad along with each item to the `startTracking` method.

For Swift:
```swift
ad.startTrackingView(<AD_CONTAINER_VIEW_GROUP>, withViewController:<CONTROLLER>)
```

For Objective-C:
```objective-c
[ad startTrackingView:<AD_CONTAINER_VIEW_GROUP> withViewController:<CONTROLLER>];
```
<a name="usage_ad_delegate"></a>
### Ad model delegate

If you want to know when Ad will be clicked or will confirm impression you can use `PubnativeAdModelDelegate` from `PubnativeAdModel`. 

For Swift:
```swift
class YourClass: PubnativeAdModelDelegate {
//...
model.delegate = self
//...
func pubantiveAdDidConfirmImpression(ad: PubnativeAdModel!)
{
    //Impression was just recorded
}

func pubnativeAdDidClick(ad: PubnativeAdModel!)
{
    //The ad was clicked, the ad will be opened right after this
}
```

For Objective-C:
```objective-c
@interface YourInterface () PubnativeAdModelDelegate
//...
model.delegate = self;
//...
- (void)pubantiveAdDidConfirmImpression:(PubnativeAdModel *)ad
{
    //Impression was just recorded
}

- (void)pubnativeAdDidClick:(PubnativeAdModel *)ad
{
    //The ad was clicked, the ad will be opened right after this
}
```
<a name="usage_targeting_ad"></a>
### Targeting ad

If you want to use targeting for the Ads, you need to create `PubnativeAdTargetingModel` and fill it with data. Then set targeting with `setTargeting` from `PubnativeNetworkRequest`.

For Swift:
```swift
var targeting = PubnativeAdTargetingModel()
targeting.age = <AGE>
targeting.education = "<EDUCATION>"
targeting.interests = <ARRAY_OF_THE_INTERESTS>
targeting.gender = "<GENDER>"     // "F" for female, "M" for male
targeting.iap = <IAP>             // In app purchase enabled, Just open it for the user to fill
targeting.iap_total = <IAP_TOTAL> // In app purchase total spent, just open for the user to fill
networkRequest.setTargeting(targeting)
```

For Objective-C:
```objective-c
PubnativeAdTargetingModel *targeting = [[PubnativeAdTargetingModel alloc] init];
targeting.age = <AGE>;
targeting.education = "<EDUCATION>";
targeting.interests = <ARRAY_OF_THE_INTERESTS>;
targeting.gender = "<GENDER>";     // "F" for female, "M" for male
targeting.iap = <IAP>;             // In app purchase enabled, Just open it for the user to fill
targeting.iap_total = <IAP_TOTAL>; // In app purchase total spent, just open for the user to fill
[networkRequest setTargeting:targeting];
```

<a name="networks"></a>
# Third party networks

In order to integrate third party networks you need to do the following:

1. Integrate third party SDK as detailed in that SDK integration instructions
2. Copy the desired adapter network and model (they have to remain in the same package) to your project, our currently supported network adapters can be found [here](https://github.com/pubnative/pubnative-ios-mediation-sdk/tree/documentation/mediation/mediation.adapters)
3. Ensure to add the network in Pubnative dashboard priorities

Once this integration steps are accomplished, you'll start receiving ads from those networks too.

<a name="misc"></a>
# Misc

<a name="misc_license"></a>
### License

This code is distributed under the terms and conditions of the MIT license.

<a name="misc_contributing"></a>
### Contributing

**NB!** If you fix a bug you discovered or have development ideas, feel free to make a pull request.