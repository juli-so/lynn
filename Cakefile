{exec, spawn} = require 'child_process'

task 'build', 'building from src/ to lib/', ->
  exec 'coffee -o lib --no-header -bc src', (err, stdout, stderr) ->
    throw err if err
    console.log 'Coffee: build complete'
  exec 'jade -P option', (err, stdout, stderr) ->
    throw err if err
    console.log 'Jade: build complete'

task 'watch', 'watching src/ and build to lib/', ->
  coffeeProc = spawn 'coffee', '-o lib --no-header -bcw src'.split(' ')
  coffeeProc.stdout.on 'data', (data) -> process.stdout.write data
  coffeeProc.on 'exit', (returnCode) -> process.exit returnCode

  jadeProc = spawn 'jade', '-Pw'.split(' ')
  jadeProc.stdout.on 'data', (data) -> process.stdout.write data
  jadeProc.on 'exit', (returnCode) -> process.exit returnCode

task 'clean', 'clean lib folder', ->
  exec 'rm -f 
    lib/background/* 
    lib/content_script/* 
    lib/option/* 
    option/option.html 
    option/jade_includes/*.html',
    (err, stdout, stderr) ->
    throw err if err
    console.log 'finished cleaning'

