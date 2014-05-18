##############################################################################
#
# Command is dedicated to processing input from 
#
# Command definition
#   -> Command syntax
#   -> Structure of request and response
#
# Command processor
#   -> Manage a port to background
#   -> Create request epending on command
#   -> Add listener to port
#
##############################################################################


##############################################################################
#
# Command definition
#   Command syntax
#     -> Word          alphanumeric | - | _
#     -> Token         word | @word | #word | /word
#     -> Query         [token]
#     -> Command       !word + query | :word + query
#
#   Request
#     {
#       request: 'search'
#       command: string
#     }
#
#   Response
#     {
#       response: 'search'
#       result: [BookmarkTreeNode]
#     }
#
##############################################################################


Command =
  port: {}

  init: ->
    @port = chrome.runtime.connect({ name: 'm_request' })

  # Create request from command
  request: (command) ->
    tokenArray = command.split()
    # Command
    if tokenArray[0][0] == '!' or tokenArray[0][0] == ':'
      # do something
    # Query
    else
      {
        request: 'search'
        command: command
      }

  postMessage: (message) ->
    @port.postMessage(message)

  addListener: (callback) ->
    @port.onMessage.addListener(callback)
