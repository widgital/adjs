// Generated by CoffeeScript 1.7.1
(function() {
  var Request, currentName, events, sf, stream, utils;

  currentName = window.name;

  sf = require('../node_modules/safeframe/lib/js/ext/ext')(true);

  events = require('./shared/event')(["request", "load", "view", "click", "expanded", "collapsed", "engage", "unview", "unload"]);

  utils = require('./shared/utils');

  Request = require('./request');

  stream = require('./shared/stream');

  (function(sf, window) {
    var AdJS, VIEWED_STRIKE, attributes, didShow, forceNuke, height, host, isViewedInterval, location, onUpdate, referrerLevel, registerAdJSendpoints, registerForEvents, registered, request, requested, setSessionInfo, sfDom, showAd, showAdTimer, showPage, unviewedTicks, updateIsViewed, updateReferrer, viewedTicks, width;
    request = new Request();
    request.change(function() {
      return stream.event(request);
    });
    sfDom = sf.lib.dom;
    AdJS = {};
    VIEWED_STRIKE = 9;
    viewedTicks = 0;
    unviewedTicks = 0;
    width = window.innerWidth;
    height = window.innerHeight;
    registered = false;
    didShow = false;
    requested = false;
    attributes = {};
    AdJS.setDimensions = function(w, h) {
      width = w;
      return height = h;
    };
    registerForEvents = function() {
      registered = true;
      return $sf.ext.register(width, height, onUpdate);
    };
    registerAdJSendpoints = function() {
      return true;
    };
    setSessionInfo = function(cookieData) {
      return request.set(utils.fromQuery(cookieData));
    };
    updateReferrer = function(level) {
      if (level == null) {
        level = "all";
      }
      switch (level) {
        case "all":
          return true;
        case "host":
          utils.defineProperty(document, "referrer", {
            get: function() {
              return "" + document.location.protocol + "//" + host;
            }
          });
          return true;
        case "none":
          return false;
        default:
          return true;
      }
    };
    onUpdate = function(status, data) {
      switch (status) {
        case "expanded":
          return function() {
            return AdJS.expanded();
          };
        case "collapsed":
          return function() {
            return AdJS.collapsed();
          };
        case "geom-update":
          return showAd();
        case "cookie-update":
          return setSessionInfo(unescape(data.value));
        case "engaged":
          return AdJS.engage();
        case "requested":
          if (!requested) {
            return AdJS.request();
          }
      }
    };
    isViewedInterval = null;
    updateIsViewed = function() {
      var _base, _base1;
      if (!AdJS.isViewed && (typeof (_base = $sf.ext).inViewPercentage === "function" ? _base.inViewPercentage() : void 0) > 50 && $sf.ext.winHasFocus()) {
        viewedTicks++;
      } else if (AdJS.isViewed && ((typeof (_base1 = $sf.ext).inViewPercentage === "function" ? _base1.inViewPercentage() : void 0) < 50 || !$sf.ext.winHasFocus())) {
        unviewedTicks++;
      } else {
        unviewedTicks = viewedTicks = 0;
      }
      if (viewedTicks === VIEWED_STRIKE) {
        if (!AdJS.isViewed) {
          AdJS.view();
        }
        AdJS.isViewed = true;
      }
      if (unviewedTicks === VIEWED_STRIKE) {
        if (!AdJS.isunViewed) {
          AdJS.unview();
        }
        AdJS.isunViewed = true;
        return clearInterval(isViewedInterval);
      }
    };
    showAdTimer = null;
    showAd = function(show) {
      var startTime, _base;
      if (((typeof (_base = $sf.ext).inViewPercentage === "function" ? _base.inViewPercentage() : void 0) > 5 && !didShow) || show) {
        if (showAdTimer) {
          clearInterval(showAdTimer);
        }
        startTime = utils.now();
        AdJS.request();
        $sf.ext.showAd(function() {
          return AdJS.load();
        });
        return didShow = true;
      } else if (!(showAdTimer || didShow)) {
        return showAdTimer = setInterval(forceNuke, 50);
      }
    };
    forceNuke = function() {
      var _base;
      if ((typeof (_base = $sf.ext).inViewPercentage === "function" ? _base.inViewPercentage() : void 0) > 5 && showAdTimer) {
        clearInterval(showAdTimer);
        showAdTimer = null;
        return $sf.ext.reload();
      }
    };
    sf.lib.lang.mix(AdJS, events);
    AdJS.on = function(event, cb) {
      return events.on.apply(this, [event, cb]);
    };
    AdJS.expand = function(deltaXorDesc, deltaY, p) {
      return $sf.ext.expand(deltaXorDesc, deltaY, p);
    };
    AdJS.collapse = function() {
      return $sf.ext.collapse();
    };
    AdJS.cookie = function(cookieName, cookieData) {
      return $sf.ext.cookie(coookieName, cookieData);
    };
    AdJS.supports = function(key) {
      return $sf.ext.supports(key);
    };
    AdJS.sendMessage = function(content) {
      return setTimeout(function() {
        return $sf.ext.message(encodeURIComponent(content));
      }, 1);
    };
    sfDom.attach(document.body, "mouseup", function() {
      AdJS.click();
      return true;
    });
    window.$ad = AdJS;
    registerAdJSendpoints();
    AdJS.click(function() {
      return sf.ext.click();
    });
    AdJS.view(function() {
      return sf.ext.viewed();
    });
    AdJS.unview(function() {
      return sf.ext.unviewed();
    });
    AdJS.load(function() {
      return registerForEvents();
    });
    AdJS.load(function() {
      return isViewedInterval = setInterval(updateIsViewed, 100);
    });
    AdJS.load(function() {
      AdJS.frameCount = utils.countFrames(window);
      return request.set({
        frame_count: AdJS.frameCount
      });
    });
    AdJS.request(function() {
      AdJS.requestTime = utils.now();
      return request.set({
        requested: true,
        requestedAt: utils.now()
      });
    });
    AdJS.load(function() {
      AdJS.loadTime = utils.now();
      sfDom.attach(window, "unload", function() {
        return $ad.unload();
      });
      return request.set({
        loaded: true,
        loadedAt: utils.now()
      });
    });
    AdJS.view(function() {
      AdJS.viewTime = utils.now();
      return request.set({
        viewed: true,
        viewedAt: utils.now()
      });
    });
    AdJS.engage(function() {
      AdJS.engageTime = utils.now();
      return request.set({
        engaged: true,
        engagedAt: utils.now()
      });
    });
    AdJS.click(function() {
      AdJS.clickTime = utils.now();
      return request.set({
        clicked: true,
        clickedAt: utils.now()
      });
    });
    AdJS.unview(function() {
      AdJS.unviewTime = utils.now();
      return request.set({
        unviewed: true,
        unviewedAt: utils.now()
      });
    });
    AdJS.unload(function() {
      AdJS.unloadTime = utils.now();
      return request.set({
        unloaded: true,
        unloadedAt: utils.now()
      });
    });
    sf.ext.render(false);
    didShow = !sf.lib.lang.cbool(sf.ext.meta("inview", "extended"));
    referrerLevel = sf.ext.meta("referrer", "extended") || "all";
    host = sf.ext.meta("host", "extended");
    sf.ext.deleteMeta("host", "extended");
    location = sf.ext.meta("location", "extended");
    sf.ext.deleteMeta("location", "extended");
    setSessionInfo(sf.ext.meta("session", "extended"), {
      silent: true
    });
    sf.ext.deleteMeta("session", "extended");
    $ad.slotId = sf.ext.meta("slot_id", "extended");
    $ad.count = sf.ext.meta("slot_count", "extended");
    request.set({
      slot_id: sf.ext.meta("slot_id", "extended"),
      slot_count: sf.ext.meta("slot_count", "extended"),
      page_url: location,
      page_host: host
    }, {
      silent: true
    });
    showPage = document.location.href === document.referrer || updateReferrer(referrerLevel);
    if (showPage) {
      showAd(didShow);
    } else {
      window.name = currentName;
      document.location = document.location;
    }
    return AdJS;
  })(sf, window);

}).call(this);