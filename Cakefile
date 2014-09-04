{exec, spawn} = require 'child_process'

task 'build', 'building from src/ to lib/', ->
  exec 'coffee -o lib --no-header -bc src', (err, stdout, stderr) ->
    throw err if err
    console.log 'Coffee: build complete'
  exec 'jade -P optionPage', (err, stdout, stderr) ->
    throw err if err
    console.log 'Jade: build complete'

task 'watch', 'watching src/ and build to lib/', ->
  coffeeProc = spawn 'coffee', '-o lib --no-header -bcw src'.split(' ')
  coffeeProc.stdout.on 'data', (data) -> process.stdout.write data
  coffeeProc.stderr.on 'data', (data) -> process.stderr.write data
  coffeeProc.on 'exit', (returnCode) -> process.exit returnCode

  jadeProc = spawn 'jade', '-Pw optionPage'.split(' ')
  jadeProc.stdout.on 'data', (data) -> process.stdout.write data
  jadeProc.stderr.on 'data', (data) -> process.stderr.write data
  jadeProc.on 'exit', (returnCode) -> process.exit returnCode

task 'clean', 'clean lib folder', ->
  exec 'rm -rf 
    lib/*
    optionPage/*.html',
    (err, stdout, stderr) ->
      throw err if err
      console.log 'finished cleaning'
