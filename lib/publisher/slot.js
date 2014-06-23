// Generated by CoffeeScript 1.7.1
(function() {
  var events, sf, sfDom, sizes, utils,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  sf = require('safeframe');

  sizes = require('../shared/sizes');

  utils = require('../shared/utils');

  events = require('../shared/event')(["request", "click", "load", "view", "unload", "focus", "engage", "unfocus", "expand", "collapse", "refreshed", "cookie", "receive", "unview", "timeout"]);

  sfDom = sf.lib.dom;

  module.exports = (function() {
    var SCRIPT_REGEX, Slot, TIMEOUT_TIME, oldTrigger, slots;
    TIMEOUT_TIME = 5000;
    slots = {};
    SCRIPT_REGEX = /<!--([\s\S]*)-->/;
    Slot = (function() {
      function Slot(adId) {
        this.trigger = __bind(this.trigger, this);
        if (this instanceof Slot) {
          return this.init(adId);
        } else {
          return new Slot(adId);
        }
      }

      Slot.prototype.init = function(adId) {
        if (slots[adId]) {
          return slots[adId];
        }
        this.id = adId;
        this.count = 1;
        slots[adId] = this;
        return this.initEvents();
      };

      Slot.prototype.startAutoRefresh = function(delay, cb) {
        if (delay == null) {
          delay = 60;
        }
        if (!this._isAutoRefreshing) {
          this._isAutoRefreshing = true;
          this._refreshInterval = setTimeout((function(_this) {
            return function() {
              _this._isAutoRefreshing = false;
              if (_this.loadTime) {
                return _this.refresh(cb);
              }
            };
          })(this), delay * 1000);
        }
        return this;
      };

      Slot.prototype.stopAutoRefresh = function() {
        clearTimeout(this._refreshInterval);
        this._isAutoRefreshing = false;
        this._refreshInterval = null;
        return this;
      };

      Slot.prototype.refresh = function(cb) {
        this.remove();
        this.count++;
        this.posMeta.setValue("slot_count", "extended", this.count);
        sf.host.render(this.pos);
        this.frame = document.getElementById(this.posConfig.dest);
        if (typeof cb === "function") {
          cb(this);
        }
        this.refreshed();
        return this;
      };

      Slot.prototype.trigger = function(event) {
        var _ref;
        if (!((_ref = this.options) != null ? _ref.ignoreEvents : void 0)) {
          events.trigger.apply(this, arguments);
          Slot.trigger(event, this, arguments[1]);
        }
        return this;
      };

      Slot.prototype.handleMessage = function(msg, content) {
        switch (msg) {
          case "focus-change":
            if (content) {
              return this.focus();
            } else {
              return this.unfocus();
            }
            break;
          case "geom-update":
            return function() {};
          case "expand":
            return this.expand(content);
          case "collapse":
            return this.collapse(content);
          case "viewed":
            if (!this.viewed) {
              return this.view();
            }
            break;
          case "unviewed":
            if (!(this.unviewed && this.viewed)) {
              return this.unview();
            }
            break;
          case "clicked":
            if (!this.clicked) {
              return this.click();
            }
            break;
          case "requested":
            return this.request();
          case "cookie-write":
            return this.cookie({
              cookie: "write",
              content: content
            });
          case "cookie-read":
            return this.cookie({
              cookie: "read",
              content: content
            });
          case "reload":
            return this.reload();
          case "msg":
            return this.receive(decodeURIComponent(content));
          default:
            return null;
        }
      };

      Slot.prototype.initEvents = function() {
        this.request(function() {
          return this.requestTime = utils.now();
        });
        this.load(function() {
          this.frameCount = utils.countFrames(this.frame.contentWindow);
          return this.loadTime = utils.now();
        });
        this.view(function() {
          this.viewed = true;
          return this.viewTime = utils.now();
        });
        this.engage(function() {
          if (!this.engaged) {
            this.engaged = true;
            this.engageTime = utils.now();
            return this.notifyFrame("engaged");
          }
        });
        this.unview(function() {
          this.unviewed = true;
          return this.unviewTime = utils.now();
        });
        this.unload(function() {
          return this.unloadTime = utils.now();
        });
        return this.click(function() {
          return this.clicked = true;
        });
      };

      Slot.prototype.frameCount = 0;

      Slot.prototype.notifyFrame = function(cmd, data) {
        var msgObj;
        msgObj = sf.lib.lang.ParamHash();
        if (this.posConfig) {
          msgObj.pos = this.posConfig.id;
          msgObj.cmd = cmd;
          msgObj.value = escape(data);
          return sfDom.msghost.send(this.posConfig.dest, msgObj.toString());
        }
      };

      Slot.prototype.create = function(elem, html, options) {
        var height, s, supports, width, _i, _j, _len, _len1, _ref, _ref1;
        this.options = options != null ? options : {};
        width = this.options.width || elem.offsetWidth;
        height = this.options.height || elem.offsetHeight;
        supports = {};
        _ref = this.options.supports || [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          s = _ref[_i];
          supports[s] = true;
        }
        _ref1 = this.options.disables || [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          s = _ref1[_j];
          supports[s] = false;
        }
        if (this.elem) {
          return;
        }
        this.elem = elem;
        elem.id || (elem.id = sf.lib.lang.guid("pos"));
        this.posMeta = new sf.host.PosMeta(null, "extended", {
          inview: this.options.inview,
          session: this.options.session,
          host: document.location.hostname,
          referrer: this.options.referrer,
          location: document.location.href,
          slot_id: this.id,
          slot_count: this.count
        });
        this.posConfig = new sf.host.PosConfig({
          id: this.id,
          dest: elem.id,
          w: width,
          h: height,
          supports: supports
        });
        this.pos = new sf.host.Position(this.posConfig.id, html, this.posMeta);
        if (this.options.refresh_oov) {
          this.unview(function() {
            return setTimeout((function(_this) {
              return function() {
                return _this.refresh();
              };
            })(this), 1);
          });
        }
        if (this.options.refresh_time != null) {
          this.refreshTime = sf.lib.lang.cnum(this.options.refresh_time, 0);
          if (this.refreshTime > 0) {
            this.load(function() {
              return this.startAutoRefresh(this.refreshTime);
            });
            this.timeout(function() {
              this.stopAutoRefresh();
              return this.refresh();
            });
          }
        }
        sf.host.render(this.pos);
        this.frame = document.getElementById(elem.id);
        return this;
      };

      Slot.prototype.remove = function(dontFire) {
        if (!dontFire) {
          this.unload();
        }
        clearTimeout(this._refreshInterval);
        this.viewed = false;
        this.engaged = false;
        this.unviewed = false;
        this.frame = null;
        this.frameCount = 0;
        this.requestTime = null;
        this.loadTime = null;
        this.viewTime = null;
        this.engageTime = null;
        this.unviewTime = null;
        this.unloadTime = null;
        sf.host.nuke(this.id);
        return this;
      };

      Slot.prototype.destroy = function() {
        this.stopAutoRefresh();
        this.remove();
        delete this.events;
        return delete slots[this.id];
      };

      Slot.prototype.reload = function() {
        if (this.options.inview) {
          this.remove(true);
          sf.host.render(this.pos);
          return this.frame = document.getElementById(this.posConfig.dest);
        }
      };

      Slot.prototype.currentlyInview = function() {
        return sf.host.inViewPercentage(this.id) > 50 && this.viewed;
      };

      Slot.prototype.inviewPercentage = function() {
        return sf.host.inViewPercentage(this.id);
      };

      return Slot;

    })();
    Slot.destroy = function() {
      var ad, _, _results;
      _results = [];
      for (_ in slots) {
        ad = slots[_];
        _results.push(ad.destroy());
      }
      return _results;
    };
    Slot.events = {};
    oldTrigger = Slot.prototype.trigger;
    sf.lib.lang.mix(Slot.prototype, events);
    Slot.prototype.trigger = oldTrigger;
    sf.lib.lang.mix(Slot, events);
    Slot.create = function(d, session) {
      var adId, disables, div, height, posId, size, supports, template, width, _base, _base1, _ref;
      template = ((_ref = d.innerHTML.match(SCRIPT_REGEX)) != null ? _ref[1] : void 0) || d.innerHTML;
      posId = sf.lib.lang.guid("pos");
      adId = d.id || posId;
      div = document.createElement("div");
      div.id = posId;
      d.appendChild(div);
      supports = [];
      disables = [];
      if (size = sizes[sfDom.attr(d, "data-ad-type")]) {
        width = size[0], height = size[1];
      }
      Slot(adId).create(div, template, {
        width: width || sfDom.attr(d, "data-width"),
        height: height || sfDom.attr(d, "data-height"),
        supports: typeof (_base = sfDom.attr(d, "data-supports")).split === "function" ? _base.split(",") : void 0,
        disables: typeof (_base1 = sfDom.attr(d, "data-disables")).split === "function" ? _base1.split(",") : void 0,
        inview: sf.lib.lang.cbool(sfDom.attr(d, "data-inview")),
        refresh_time: sfDom.attr(d, "data-refresh-time"),
        refresh_oov: sf.lib.lang.cbool(sfDom.attr(d, "data-refresh-oov")),
        session: session != null ? session.serializeCookie() : void 0,
        referrer: sfDom.attr(d, "data-referrer"),
        ignoreEvents: sf.lib.lang.cbool(sfDom.attr(d, "data-ignore-events"))
      });
      return Slot(adId);
    };
    Slot.slots = slots;
    Slot.sizes = sizes;
    return Slot;
  })();

}).call(this);