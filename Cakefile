{exec} = require 'child_process'

task 'build', 'building from src/ to lib/', ->
  exec 'coffee -o lib/background --no-header -bc src/background/*.coffee', (err, stdout, stderr) ->
    throw err if err
    console.log 'Coffee: background script compiled'
  exec 'coffee -o lib/content_script --no-header -bc src/content_script/*.coffee', (err, stdout, stderr) ->
    throw err if err
    console.log 'Coffee: content script compiled'

task 'clean', 'clean lib folder', ->
  exec 'rm -f lib/background/* lib/content_script/*', (err, stdout, stderr) ->
    throw err if err
    console.log 'finished cleaning'

