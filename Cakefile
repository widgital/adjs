{print} = require 'util'
{spawn} = require 'child_process'
fs = require 'fs'

AWS = require 'aws-sdk'
AWS.config.update
  accessKeyId: process.env.AMAZON_ACCESS_KEY_ID,
  secretAccessKey: process.env.AMAZON_SECRET_ACCESS_KEY
  region: process.env.AMAZON_REGION or "us-east-1"



task 'build', 'Build lib/ from src/', ->
  coffee = spawn 'coffee', ['-c', '-o', 'lib', 'src']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', (code) ->
    callback?() if code is 0

task 'watch', 'Watch src/ for changes', ->
  coffee = spawn 'coffee', ['-w', '-c', '-o', 'lib', 'src']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()

task 'watchify', 'watch /debug files',->
  watchifyProcs = []
  watchifyProcs.push(spawn 'watchify', ['--debug', 'lib/frame.js', '-o', 'lib/frame.ad.js', '-v','-t','envify'])
  watchifyProcs.push(spawn 'watchify', ['--debug', 'lib/publisher.js' ,'-o' ,'lib/publisher.ad.js', '-v','-t','envify'])
  watchifyProcs.push(spawn 'watchify', ['--debug', 'lib/adframe.js', '-o', 'lib/adframe.ad.js', '-v'])
  watchifyProcs.push(spawn 'watchify', ['--debug', 'lib/controller.js', '-o', 'lib/controller.ad.js', '-v'])
  watchifyProcs.push(spawn 'watchify', ['--debug', 'lib/advertiser.js', '-o', 'lib/advertiser.ad.js', '-v'])
  for p in watchifyProcs
    p.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    p.stdout.on 'data', (data) ->
      print data.toString()
task 'build', 'build different files',->
  watchifyProcs = []
  watchifyProcs.push(spawn 'browserify', [ 'lib/frame.js', '-o', 'lib/dist/frame.ad.js','-t','envify'])
  watchifyProcs.push(spawn 'browserify', [ 'lib/publisher.js' ,'-o' ,'lib/dist/publisher.ad.js','-t','envify'])
  watchifyProcs.push(spawn 'browserify', [ 'lib/adframe.js', '-o', 'lib/dist/adframe.ad.js','-t','envify'])
  watchifyProcs.push(spawn 'browserify', [ 'lib/controller.js', '-o', 'lib/dist/controller.ad.js','-t','envify'])
  watchifyProcs.push(spawn 'browserify', [ 'lib/advertiser.js', '-o', 'lib/dist/advertiser.ad.js','-t','envify'])
  for p in watchifyProcs
    p.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    p.stdout.on 'data', (data) ->
      print data.toString()
task 'minify', 'minify different files',->
  watchifyProcs = []
  watchifyProcs.push(spawn 'uglifyjs', [ 'lib/dist/frame.ad.js', '-o', 'lib/dist/frame.ad.min.js','-c'])
  watchifyProcs.push(spawn 'uglifyjs', [ 'lib/dist/publisher.ad.js' ,'-o' ,'lib/dist/publisher.ad.min.js','-c'])
  watchifyProcs.push(spawn 'uglifyjs', [ 'lib/dist/adframe.ad.js', '-o', 'lib/dist/adframe.ad.min.js','-c'])
  watchifyProcs.push(spawn 'uglifyjs', [ 'lib/dist/controller.ad.js', '-o', 'lib/dist/controller.ad.min.js','-c'])
  watchifyProcs.push(spawn 'uglifyjs', [ 'lib/dist/advertiser.ad.js', '-o', 'lib/dist/advertiser.ad.min.js','-c'])
  for p in watchifyProcs
    p.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    p.stdout.on 'data', (data) ->
      print data.toString()
task 'upload', 'upload files to s3',->
  s3 = new AWS.S3()
  jsFiles = fs.readdirSync("./lib/dist/").filter (f)-> f.match(/[.]js$/)
  for f in jsFiles
    do (f)->
      fs.readFile "./lib/dist/#{f}", (err,body)->
        s3.putObject
          Bucket: process.env.S3_BUCKET || "cdn.adjs.net"
          Key: f
          Body: body
          ContentType: "application/javascript"
          ACL: "public-read"
        ,(err,data)->
          console.log(err, err.stack) if err
          console.log(data) unless err
  htmlFiles = fs.readdirSync("./lib/dist/html").filter (f)-> f.match(/[.]html$/)
  for f in htmlFiles
    do (f)->
      fs.readFile "./lib/dist/html/#{f}", (err,body)->
        s3.putObject
          Bucket: process.env.S3_BUCKET || "cdn.adjs.net"
          Key: "html#{f}"
          Body: body
          ContentType: "text/html"
          ACL: "public-read"
        ,(err,data)->
          console.log(err, err.stack) if err
          console.log(data) unless err

task 'test', 'Run tests', ->
  mocha = spawn 'mocha', ['--compilers', 'coffee:coffee-script']
  mocha.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  mocha.stdout.on 'data', (data) ->
    print data.toString()