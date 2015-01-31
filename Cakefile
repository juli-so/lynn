{exec, spawn} = require 'child_process'

task 'build', 'building from src/ to bin/', ->
  exec 'coffee -o bin --no-header -bc src', (err, stdout, stderr) ->
    throw err if err
    console.log 'Coffee: Lynn built'
  exec 'coffee -o options/site/js --no-header -bc options/coffee', (err, stdout, stderr) ->
    throw err if err
    console.log 'Coffee: options page built'
  exec 'jade -o options/site/html -P options/jade', (err, stdout, stderr) ->
    throw err if err
    console.log 'Jade:   options page built'

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

task 'clean', 'clean bin folder', ->
  exec 'rm -rf 
    bin/*
    options/site/html
    options/site/js',
    (err, stdout, stderr) ->
      throw err if err
      console.log 'Done cleaning'
