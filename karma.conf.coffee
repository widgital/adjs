# Karma configuration
# Generated on Mon Jun 09 2014 15:56:06 GMT-0400 (EDT)
module.exports = (config) ->
  customLaunchers =
    sl_ios_safari:
      base: "SauceLabs"
      browserName: "iphone"
      platform: "OS X 10.9"
      version: "7.1"

    sl_ie_8:
      base: "SauceLabs"
      browserName: "internet explorer"
      platform: "Windows xp"
      version: "8"
    sl_android:
      base:"SauceLabs"
      browserName:"android"
      platform:"Linux"
      version:"4.3"
      deviceName:"LG Nexus 4 Emulator"



  config.set

    sauceLabs:
      testName: 'Ad.js Specs'


  # base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: "./"
    files:[
#      'src/**/*.coffee',
      {pattern:'node_modules/jquery/dist/jquery.js', watched: false, served: true, included: true}
      {pattern:'node_modules/jasmine-jquery/lib/jasmine-jquery.js', watched: false, served: true, included: true},
      'lib/html/adjsframe.html',
      'spec/**/*.coffee',
      'spec/fixtures/**/*.html',
      'lib/frame.ad.js'

    ]
  # frameworks to use
  # available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ["jasmine","browserify"]



  # list of files to exclude
    exclude: []

  # preprocess matching files before serving them to the browser
  # available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors:
#      '**/*.coffee': 'coffee'
      'spec/**/*.coffee': ['browserify']
    browserify:
      extensions: ['.coffee']
      transform: ['coffeeify']
      watch: true   # Watches dependencies only (Karma watches the tests)
      debug: true   # Adds source maps to bundle

  # test results reporter to use
  # possible values: 'dots', 'progress'
  # available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ["progress","saucelabs"]

  # web server port
    port: 9876

  # enable / disable colors in the output (reporters and logs)
    colors: true

  # level of logging
  # possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO

  # enable / disable watching file and executing tests whenever any file changes
    autoWatch: true
    customLaunchers: customLaunchers,
  # start these browsers
  # available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ["Chrome","sl_ie_8"]

  # Continuous Integration mode
  # if true, Karma captures browsers, runs the tests and exits
    singleRun: true
    client:
      useIframe: false

  return