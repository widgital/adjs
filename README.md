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
