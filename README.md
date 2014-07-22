Ad.js
=====

Ad.js is an ad library simplifies many of the tasks needed by ad companies so that they can focus on higher value features. Ad.js is open source, and can be used locally, or using the Ad.js CDN.
This library is designed to make display advertising simpler and more effective for publishers, advertisers, data providers, and other ad technology providers.
 
Some of the features of Ad.js:

* IAB Compliant ad tracking (views and clicks)
* IAB compliant ad in-view tracking (geometric and flash-pixel)
* Expandable ad support
* [SafeFrame](http://www.iab.net/safeframe) compliance

## More Information

* [API Explorer](http://developer.adjs.io/explorer)
* [API Documentation](http://developer.adjs.io/api)


## Installation

From the adjs directory:

```
npm install
npm install -g karma-cli coffee-script watchify
```

In a separate console window, from the adjs directory:

```
cake watch
```

And in another separate console window, from the adjs directory:

```
cake watchify
```

## Testing

For browser testing
```
karma start
```

Keep Karma running and it will rerun tests as you make changes

To use sauce labs:
make sure process.env.SAUCE_USERNAME and process.env.SAUCE_ACCESS_KEY
set singleRun:true in the karma.conf.coffee


### Building the distribution

```
ENV=production CDN_URL=//js.adjs.net cake build


```


## Service Description

![Ad.js Services Architecture](https://docs.google.com/a/adjs.io/drawings/d/1COgQlApY42M9cAMgkoFOQl8oLuoHJJN7fXGRaOI06Ms/pub?w=954&h=738)

The Ad.js framework can be broken down into the following components:

### Core

#### Event Stream

* Event Register (ability for an advertiser, ad network, data provider to be notified of events)
* Stream API (all events get passed to the Ad.js service through the Stream API)
* Standards Complicance (IAB user, visit, safeframe object, MRC load, in-view counting methodologies)
* Plugin Architecture (how to build on top of this component, documentation, etc.)
* Async communication
* Page level vs. ad level properties
* Storing offline events
 
#### Communication Channel

* Data Channel (channel for communication between the publisher and advertisers (and other interested parties)
* Security / Permissions Model (turn on/off ability for advertisers to look at particular publisher info)
* Publisher Properties (domain, URL, DOM, words)

#### Helper Functions

* Automatically put ad tags into a safeframe
* Service Discovery (can I use geolocation, accelerometer, etc?)
* Server Side Rendering (render on phantomjs on CDN and pass back final result)

#### Default Plugins

* IAB Standard Events (requests, impressions, clicks, conversions)
* In-View Event (geometric / flash)
* Expandable (frames can be promoted to publisher to they can expand)
* Ad and page speed tracking

#### Integrations

* Advertiser Integration (iAd, Doubleclick Rich Media Library)
* Mobile SDK integrations (e.g. mopub on android and iphone)
* Website integrations (e.g. Tumblr, Wordpress, Square Space, etc.)

### Plugins

#### In-View

* See Thru (can we view all the way to the top of the page?)
* Geometric in-view (e.g. like comscore, geometry of page, position of ad on page)
* Flash Pixel in-view (e.g. like spider)
* IAB Standard In-View event
* Custom events for more detailed in-view info

#### Creative

* Publisher Look and Feel (CSS control by publisher, font, background and foreground colors, etc.)
* Helper functions (e.g. JQuery UI for ads)
* Auto Fallback (SVG -> HTML5 -> Image)
* Different image sizes for different screen sizes
* Muli-ad per device
* Auto-expand (use communication channel to allow an expandable ad to display on publisher site)
* Standardize mobile events (e.g. send me more info, call, like, etc.) without going to another app/browser/etc.
* Transitions on mobiles and tablets

#### Content Verification

* Categorization of inventory
* Blocking
* Spider to verify page content
* Number of ads on a page
* Companion positioning?
* Ad Position (x/y)
* Malware (check pages from different locations)
* Quality Score (e.g. how well integrated advertising is in a publisher site)
* Ad Categorization (e.g. for each ad, place in a content category, whether it can be 'native', etc.)

#### Integrations

* RTB Integration (Appnexus, OpenX, etc.)
* Adserver Integration (Doubleclick, etc.)
* Data Integration (Alenty, Experian, etc.)
* Ad Network SDK (Mopub, etc.)

#### Click-to-call

* Track clicks through to calling a number

#### Data

* User Identification (integration of 1st and 3rd party cookies, hash of email, across devices)
* Device ID
* URL Category
* Seen Before (has this person been seen before?)
* Clicked Before (has this person clicked on an ad before?)
* Purchased Before (has this person purchased something before?)

### Ad Services

#### Administration

* Publisher registration
* Add your ad tags to ad.js
* Replace existing ad tags with ad.js code

#### CDN

* Plugin Framework (ability for 3rd parties to enrich events before going to the firehose)
* Event Firehose ('spray' events to all interested parties from a CDN)
* Hosted Safeframe
* RTB inventory validation (is the pre-bid request the same as info collected on page)

#### Data Warehouse

* Summary Data API Access
* Summary Data DB Access
* Raw Data DB Access

#### UI

* Analytics (charts, etc.)
* Back end administration
* Ecommerce UI to pay for services

#### Ad Server

* Creative Server (serve ad creatives for advertisers)
* Inventory Allocation (segment requests to different RTB platforms)

## Benefits

### Publisher

* Know who is storing data about your users

#### How to install

Add this script to your head:

```
<script src='//cdn.adjs.net/adjs.min.js' data-adjs='true' data-adjs-id='CLIENT_ID_HERE'></script>
```

Replace your ad tags with the following:

```
<div id="SLOT_ID" data-width="AD_WIDTH" data-height="AD_HEIGHT" data-adjs="true" >
    <!--
    INSERT AD TAG HERE
    -->
</div>
```

Other data options to be added are as follows:
  * data-supports: Acceptable values - exp-push,read-cookie, write-cookie
  * data-disables: Acceptable values - exp-over
  * data-inview: true or false. Only show ad when page it is inview
  * data-refresh-time: any number greater than 0. Auto refresh ad after a certain period
  * data-refresh-oov: true or false. Refresh ad when its been in view and leaves view
  * data-referrer: all, host, none  - Restricts referrer from advertiser (experimental does not work in safari/mobile safari)

### Advertiser

### Ad Networks

### Data Providers


