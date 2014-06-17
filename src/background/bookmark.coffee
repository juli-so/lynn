Bookmark =
  allNode: {} # id -> Node

  nodeTagArray: {} # Node.id -> Node.tagArray
  tagNodeArray: {} # tag -> [Node.id]

  # ------------------------------------------------------------
  # Helper functions
  # ------------------------------------------------------------
  _ciContains: (str, fragment) ->
    str.toLowerCase().indexOf(fragment.toLowerCase()) isnt -1

  # ------------------------------------------------------------
  # End helper functions
  # ------------------------------------------------------------

  # ------------------------------------------------------------
  # Init
  # ------------------------------------------------------------

  # does not include directories
  init: (callback = _.noop) ->
    initNode = (node) =>
      node.isBookmark = node.url?

      if node.isBookmark
        @allNode[node.id] = node
      else
        _.forEach(node.children, initNode)

    initTag = =>
      chrome.storage.local.get ['nodeTagArray', 'tagNodeArray'], (storageObject) =>
        @nodeTagArray = storageObject['nodeTagArray'] || {}
        @tagNodeArray = storageObject['tagNodeArray'] || {}

        _.forEach @allNode, (node) =>
          if @nodeTagArray[node.id]
            node.tagArray = @nodeTagArray[node.id]
          else
            node.tagArray = @nodeTagArray[node.id] = []

        # initNode only contains synchronous calls but initTag has async calls
        # Put callback here to ensure it happens after all initiation
        callback()

    # '1' for 'Bookmarks Bar' in chrome by default
    # Later might let user specify root
    chrome.bookmarks.getSubTree '1', (nodeArray) ->
      initNode(nodeArray[0])
      initTag()

  # ------------------------------------------------------------
  # Init end
  # ------------------------------------------------------------
  
  # ------------------------------------------------------------
  # Tag operation
  # ------------------------------------------------------------
  storeTag: ->
    chrome.storage.local.set
      'nodeTagArray': @nodeTagArray
      'tagNodeArray': @tagNodeArray

  cleanTag: ->
    chrome.storage.local.set
      'nodeTagArray': []
      'tagNodeArray': []

  addTag: (node, tag) ->
    return false if tag[0] isnt '#' and tag[0] isnt '@'

    if _.contains(node.tagArray, tag)
      false
    else
      node.tagArray.push(tag)
      @tagNodeArray[tag] or= []
      @tagNodeArray[tag].push(node.id)
      true

  delTag: (node, tag) ->
    return false if tag[0] isnt '#' and tag[0] isnt '@'

    if _.contains(node.tagArray, tag)
      _.pull(node.tagArray, tag)
      _.pull(@tagNodeArray[tag], node.id)
      true
    else
      false

  # ------------------------------------------------------------
  # Tag operation end
  # ------------------------------------------------------------

  # ------------------------------------------------------------
  # Find and Filter
  # ------------------------------------------------------------
  # Change nodeArray to { node.id: node } object to allow chaining
  _toNodeObject: (nodeArray) ->
    _.zipObject(_.pluck(nodeArray, 'id'), nodeArray)

  findByTag: (tag, pool = @allNode) ->
    idList = @tagNodeArray[tag]
    _.compact(_.at(pool, idList))

  findByTagArray: (tagArray, pool = @allNode) ->
    if _.isEmpty(tagArray)
      result = pool
    else
      reduceFunc = (accumulator, tag) =>
        @_toNodeObject(@findByTag(tag, accumulator))

      result = _.reduce(tagArray, reduceFunc, pool)

    _.toArray(result)

  findByTitle: (fragment, isCaseSensitive = no, pool = @allNode) ->
    if isCaseSensitive
      _.filter pool, (node) ->
        _.contains(node.title, fragment)
    else
      _.filter pool, (node) =>
        @_ciContains(node.title, fragment)

  findByTitleArray: (fragmentArray, isCaseSensitive = no, pool = @allNode) ->
    if _.isEmpty(fragmentArray)
      result = pool
    else
      reduceFunc = (accumulator, fragment) =>
        @_toNodeObject(@findByTitle(fragment, isCaseSensitive, accumulator))

      result = _.reduce(fragmentArray, reduceFunc, pool)

    _.toArray(result)

  findByURL: (fragment, isCaseSensitive = no, pool = @allNode) ->
    if isCaseSensitive
      _.filter pool, (node) ->
        _.contains(node.url, fragment)
    else
      _.filter pool, (node) =>
        @_ciContains(node.url, fragment)

  find: (query) ->
    return [] if _.isEmpty(query)

    tokenArray = query.split(' ')
    keywordArray = []
    tagArray = []

    _.forEach tokenArray, (token) ->
      if token[0] is '#' or token[0] is '@'
        tagArray.push(token)
      else
        keywordArray.push(token)

    # If there is tag, use it to largely reduce the pool size
    if not _.isEmpty(tagArray)
      pool = @_toNodeObject(@findByTagArray(tagArray))

      return [] if _.isEmpty(pool)
      return _.toArray(pool) if _.isEmpty(keywordArray)
      console.log pool
      @findByTitleArray(keywordArray, no, pool)
    else
      @findByTitleArray(keywordArray, no, @allNode)
