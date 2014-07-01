{print} = require 'util'
{spawn} = require 'child_process'

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
  watchifyProcs.push(spawn 'watchify', ['--debug', 'lib/advertiser.js', '-o', 'lib/advertiser.ad.js', '-v'])
  watchifyProcs.push(spawn 'watchify', ['--debug', 'lib/controller.js', '-o', 'lib/controller.ad.js', '-v'])
  for p in watchifyProcs
    p.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    p.stdout.on 'data', (data) ->
      print data.toString()
task 'build', 'build different files',->
  watchifyProcs = []
  watchifyProcs.push(spawn 'browserify', [ 'lib/frame.js', '-o', 'lib/dist/frame.ad.js','-t','envify'])
  watchifyProcs.push(spawn 'browserify', [ 'lib/publisher.js' ,'-o' ,'lib/dist/publisher.ad.js','-t','envify'])
  watchifyProcs.push(spawn 'browserify', [ 'lib/advertiser.js', '-o', 'lib/dist/advertiser.ad.js'])
  watchifyProcs.push(spawn 'browserify', [ 'lib/controller.js', '-o', 'lib/dist/controller.ad.js','-t','envify'])
  for p in watchifyProcs
    p.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    p.stdout.on 'data', (data) ->
      print data.toString()

task 'upload', 'upload scripts to ec2',->



task 'test', 'Run tests', ->
  mocha = spawn 'mocha', ['--compilers', 'coffee:coffee-script']
  mocha.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  mocha.stdout.on 'data', (data) ->
    print data.toString()