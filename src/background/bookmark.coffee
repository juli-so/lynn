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
  isTag: (tag) ->
    tag[0] is '#' or tag[0] is '@'

  isntTag: (tag) ->
    not @isTag(tag)
  
  addTag: (node, tag) ->
    return false if @isntTag(tag)

    # in case the node is sent from front end
    node = @allNode[node.id]

    if _.contains(node.tagArray, tag)
      false
    else
      node.tagArray.push(tag)
      @tagNodeArray[tag] or= []
      @tagNodeArray[tag].push(node.id)
      true

  delTag: (node, tag) ->
    return false if @isntTag(tag)

    # in case the node is sent from front end
    node = @allNode[node.id]

    if _.contains(node.tagArray, tag)
      _.pull(node.tagArray, tag)
      _.pull(@tagNodeArray[tag], node.id)
      true
    else
      false

  storeTag: ->
    chrome.storage.local.set
      'nodeTagArray': @nodeTagArray
      'tagNodeArray': @tagNodeArray

  cleanTag: ->
    chrome.storage.local.set
      'nodeTagArray': []
      'tagNodeArray': []

  # ------------------------------------------------------------
  # Tag operation end
  # ------------------------------------------------------------

  # ------------------------------------------------------------
  # Find and Filter
  # ------------------------------------------------------------

  # Change nodeArray to { node.id: node } object to allow chaining
  _toNodeObject: (nodeArray) ->
    _.zipObject(_.pluck(nodeArray, 'id'), nodeArray)

  # Shortname
  _toNO: (nodeArray) ->
    _.zipObject(_.pluck(nodeArray, 'id'), nodeArray)

  # ------------------------------------------------------------

  findByTag: (tag, pool = @allNode) ->
    matchedTag = _.find Object.keys(@tagNodeArray), (t) ->
      t.toLowerCase() is tag.toLowerCase()

    idList = @tagNodeArray[matchedTag]
    _.compact(_.at(pool, idList))

  # find node that has ALL the tags in tagArray
  findByTagArray: (tagArray, pool = @allNode) ->
    if _.isEmpty(tagArray)
      result = pool
    else
      reduceFunc = (accumulator, tag) =>
        @_toNO(@findByTag(tag, accumulator))

      result = _.reduce(tagArray, reduceFunc, pool)

    _.toArray(result)

  # find node that has AT LEAST ONE tag in tagArray
  findByTagRange: (tagArray, pool = @allNode) ->
    if _.isEmpty(tagArray)
      result = pool
    else
      result = {}
      _.forEach tagArray, (tag) =>
        result = _.defaults(result, @_toNO(@findByTag(tag, pool)))

    _.toArray(result)

  findByTitle: (fragment, isCaseSensitive = no, pool = @allNode) ->
    if isCaseSensitive
      _.filter pool, (node) ->
        _.contains(node.title, fragment)
    else
      _.filter pool, (node) =>
        @_ciContains(node.title, fragment)

  # find node that has ALL fragments in fragmentArray
  findByTitleArray: (fragmentArray, isCaseSensitive = no, pool = @allNode) ->
    if _.isEmpty(fragmentArray)
      result = pool
    else
      reduceFunc = (accumulator, fragment) =>
        @_toNO(@findByTitle(fragment, isCaseSensitive, accumulator))

      result = _.reduce(fragmentArray, reduceFunc, pool)

    _.toArray(result)

  # find node that has AT LEAST ONE fragment
  findByTitleRange: (fragmentArray, isCaseSensitive = no, pool = @allNode) ->
    if _.isEmpty(fragmentArray)
      result = pool
    else
      result = {}
      _.forEach fragmentArray, (fragment) =>
        result = _.defaults(result, @_toNO(@findByTitle(fragment, no, pool)))

    _.toArray(result)

  findByURL: (fragment, isCaseSensitive = no, pool = @allNode) ->
    if isCaseSensitive
      _.filter pool, (node) ->
        _.contains(node.url, fragment)
    else
      _.filter pool, (node) =>
        @_ciContains(node.url, fragment)

  # ------------------------------------------------------------

  _suggestTag: (tagFragment) ->
    return [] if @isntTag(tagFragment)

    allTagName = Object.keys(@tagNodeArray)

    _.filter allTagName, (tag) =>
      @_ciContains(tag, tagFragment)

  find: (query, pool = @allNode) ->
    # Special cases
    return [] if _.isEmpty(query)

    if query is '#'
      return @findByTagRange(Object.keys(@tagNodeArray))

    # process query and tokenize tag and keyword
    tokenArray = query.split(' ')
    keywordArray = []
    tagArray = []

    _.forEach tokenArray, (token) =>
      if @isTag(token)
        tagArray.push(token)
      else
        keywordArray.push(token)

    if not _.isEmpty(tagArray)
      suggestedTagArray = _(tagArray)
                            .map((tag) => @_suggestTag(tag))
                            .flatten()
                            .uniq()
                            .value()
      pool = @_toNO(@findByTagRange(suggestedTagArray))

      return [] if _.isEmpty(pool)

    @findByTitleArray(keywordArray, no, pool)

  # ------------------------------------------------------------
  # Find and Filter end
  # ------------------------------------------------------------

  # ------------------------------------------------------------
  # Bookmark operation
  # ------------------------------------------------------------

  create: (bookmark, tagArray) ->
    bookmark = _.assign(bookmark, { parentId: '232' })
    chrome.bookmarks.create bookmark, (result) =>
      @allNode[result.id] = result

      result.tagArray = @nodeTagArray[result.id] = []
      _.forEach tagArray, (tag) =>
        @addTag(result, tag)
    
  move: ->
  update: ->
  remove: ->

  # ------------------------------------------------------------
  # Bookmark operation end
  # ------------------------------------------------------------
