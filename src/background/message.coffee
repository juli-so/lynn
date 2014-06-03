# Handles messages from frontend by taking action & sending back messages

Message =
  init: ->
    chrome.runtime.onConnect.addListener (port) =>
      @addListener port

  # A naive parsing of request
  parse: (request) ->
    command = ''
    option = {}

    tokenArray = request.split(' ')
    command = tokenArray[0]
    if tokenArray.length == 1
      {command}
    else
      optionString = ' ' + tokenArray.slice(1).join(' ')

      optionArray = optionString.split(' -').slice(1)

      _.forEach optionArray, (singleOption) ->
        optionName = singleOption.split(' ')[0]
        optionArgArray = singleOption.split(' ').slice(1)
        option[optionName] = optionArgArray

      {command, option}

  # Listen to message from front
  # Define stucture of messages sent to & from front
  addListener: (port) ->
    port.onMessage.addListener (message) =>
      {command, option} = @parse(message.request)
      option = {} unless option
      port.postMessage Message[command](message, option)

  # Command functions
  search: (message) ->
    response: 'search'
    result: Bookmark.find(Completion.preprocess message.command)

  open: (message, option) ->
    if option.w
      if message.node.isBookmark
        chrome.windows.create url: message.node.url
      else
        chrome.windows.create url: _.pluck(message.node.children, 'url')
    else
      openAllUnderDir = (dirNode) ->
        _.forEach dirNode.children, (child) ->
          if child.isBookmark
            chrome.tabs.create url: child.url, active: false
          else
            openAllUnderDir(child)

      if message.node.isBookmark
        chrome.tabs.create url: message.node.url, active: false
      else
        openAllUnderDir message.node
    response: 'open'

  tag: (message, option) ->
    if option.a
      _.forEach option.a, (optionArg) ->
        Bookmark.addTag message.node, optionArg
    if option.d
      _.forEach option.d, (optionArg) ->
        Bookmark.delTag message.node, optionArg

