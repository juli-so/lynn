{exec, spawn} = require 'child_process'

task 'build', 'building from src/ to lib/', ->
  exec 'coffee -o lib --no-header -bc src', (err, stdout, stderr) ->
    throw err if err
    console.log 'Coffee: background script compiled'

task 'watch', 'watching src/ and build to lib/', ->
  proc = spawn 'coffee', '-o lib --no-header -bcw src'.split(' ')
  proc.stdout.on 'data', (data) -> process.stdout.write data
  proc.on 'exit', (returnCode) -> process.exit returnCode

task 'clean', 'clean lib folder', ->
  exec 'rm -f lib/background/* lib/content_script/*', (err, stdout, stderr) ->
    throw err if err
    console.log 'finished cleaning'

