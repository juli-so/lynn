{exec, spawn} = require 'child_process'
watch         = require 'watch'
path          = require 'path'
fs            = require 'fs'

task 'build', 'building from src/ to bin/', ->
  exec 'coffee -o bin --no-header -bc src', (err) ->
    throw err if err
    console.log 'Coffee: Lynn built'
  exec 'lessc css/style.less css/style.css', (err) ->
    throw err if err
    console.log 'Less  : Lynn built'
  exec 'coffee -o options/site/js --no-header -bc options/coffee', (err) ->
    throw err if err
    console.log 'Coffee: options page built'
  exec 'jade -o options/site/html -P options/jade', (err) ->
    throw err if err
    console.log 'Jade:   options page built'
  fs.readdir 'options/less', (err, fArr) ->
    throw err if err
    fArr.forEach (f) ->
      cssf = path.basename(f).replace('.less', '.css')
      exec "lessc options/less/#{f} options/site/css/#{cssf}"
    console.log 'Less:   options page built'

task 'watch', 'watching src/ and build to bin/', ->
  coffeeProc = spawn 'coffee', '-o bin --no-header -bcw src'.split(' ')
  coffeeProc.stdout.on 'data', (data) -> process.stdout.write data
  coffeeProc.stderr.on 'data', (data) -> process.stderr.write data
  coffeeProc.on 'exit', (returnCode) -> process.exit returnCode

  coffeeProc = spawn 'coffee', '-o options/site/js --no-header -bcw options/coffee'.split(' ')
  coffeeProc.stdout.on 'data', (data) -> process.stdout.write data
  coffeeProc.stderr.on 'data', (data) -> process.stderr.write data
  coffeeProc.on 'exit', (returnCode) -> process.exit returnCode

  jadeProc = spawn 'jade', '-o options/site/html -Pw options/jade'.split(' ')
  jadeProc.stdout.on 'data', (data) -> process.stdout.write data
  jadeProc.stderr.on 'data', (data) -> process.stderr.write data
  jadeProc.on 'exit', (returnCode) -> process.exit returnCode

  # First compilation
  fs.readdir 'options/less', (err, fArr) ->
    throw err if err
    fArr.forEach (f) ->
      cssf = path.basename(f).replace('.less', '.css')
      exec "lessc options/less/#{f} options/site/css/#{cssf}"
    console.log 'Less:   options page built'

  watch.watchTree 'options/less', ignoreDotFiles: yes, (f) ->
    if typeof f isnt 'object'
      cssf = path.basename(f).replace('.less', '.css')
      exec "lessc #{f} options/site/css/#{cssf}"
      console.log "Less:   compiled #{f}"


task 'clean', 'clean bin folder', ->
  exec 'rm -rf 
    bin/*
    css/style.css
    options/site',
    (err, stdout, stderr) ->
      throw err if err
      console.log 'Done cleaning'
