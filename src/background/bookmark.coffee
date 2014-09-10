Bookmark =
  allNode: {} # id -> Node

  nodeTagMap: {} # Node.id -> Node.tagArray
  tagNodeMap: {} # tag -> [Node.id]

  # Synced to storage.sync
  lastDeletedNodeArray: []

  # Options
  MAX_RECOVER_NUM: 10

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
      chrome.storage.local.get ['nodeTagMap', 'tagNodeMap'],
        (storageObject) =>
          @nodeTagMap = storageObject['nodeTagMap'] || {}
          @tagNodeMap = storageObject['tagNodeMap'] || {}

          _.forEach @allNode, (node) =>
            if @nodeTagMap[node.id]
              node.tagArray = @nodeTagMap[node.id]
            else
              node.tagArray = @nodeTagMap[node.id] = []

          # initNode only contains synchronous calls but initTag has async calls
          # Put callback here to ensure it happens after all initiation
          callback()

    initOther = =>
      chrome.storage.sync.get null, (storageObject) =>
        @lastDeletedNodeArray =
          storageObject.lastDeletedNodeArray || @lastDeletedNodeArray
        @MAX_RECOVER_NUM =
          storageObject.MAX_RECOVER_NUM || @MAX_RECOVER_NUM

    # '1' for 'Bookmarks Bar' in chrome by default
    # Later might let user specify root
    chrome.bookmarks.getSubTree '1', (nodeArray) ->
      initNode(nodeArray[0])
      initTag()
      initOther()

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
      @tagNodeMap[tag] or= []
      @tagNodeMap[tag].push(node.id)
      true

  delTag: (node, tag) ->
    return false if @isntTag(tag)

    # in case the node is sent from front end
    node = @allNode[node.id]

    if _.contains(node.tagArray, tag)
      _.pull(node.tagArray, tag)
      _.pull(@tagNodeMap[tag], node.id)
      true
    else
      false

  delAllTag: (node) ->
    node = @allNode[node.id]

    _.remove(node.tagArray, -> true)

  # when removing a bookmark
  # all its tags should also be removed
  delAssociatedTag: (node) ->
    # in case the node is sent from front end
    node = @allNode[node.id]

    _.forEach node.tagArray, (tag) =>
      _.pull(@tagNodeMap[tag], node.id)
    _.remove(node.tagArray)

  # remove meaningless entries in nodeTagMap and tagNodeMap
  cleanTag: ->
    nodeTagMapKey = Object.keys(@nodeTagMap)
    _.forEach nodeTagMapKey, (key) =>
      if not @allNode[key]
        delete @nodeTagMap[key]

    tagNodeMapKey = Object.keys(@tagNodeMap)
    _.forEach tagNodeMapKey, (key) =>
      if _.isEmpty(@tagNodeMap[key])
        delete @tagNodeMap[key]

  storeTag: ->
    chrome.storage.local.set
      nodeTagMap: @nodeTagMap
      tagNodeMap: @tagNodeMap

  resetTag: ->
    chrome.storage.local.set
      nodeTagMap: []
      tagNodeMap: []

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
    matchedTagArray = _.filter Object.keys(@tagNodeMap), (t) ->
      t.toLowerCase() is tag.toLowerCase()

    idList = _(matchedTagArray)
               .map((matchedTag) => @tagNodeMap[matchedTag])
               .flatten()
               .uniq()
               .value()

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
        Util.ciContains(node.title, fragment)

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
        Util.ciContains(node.url, fragment)

  # ------------------------------------------------------------

  _suggestTag: (tagFragment) ->
    return [] if @isntTag(tagFragment)

    allTagName = Object.keys(@tagNodeMap)

    _.filter allTagName, (tag) =>
      Util.ciContains(tag, tagFragment)

  find: (query, pool = @allNode) ->
    # Special cases
    return [] if _.isEmpty(query)

    if query is '#' or query is '@'
      prefix = query
      tagRange = _.filter Object.keys(@tagNodeMap), (tag) ->
        Util.startsWith(tag, prefix)
      return @findByTagRange(tagRange)

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
      return [] if _.isEmpty(suggestedTagArray)

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
      result.isBookmark = yes
      result.tagArray = @nodeTagMap[result.id] = []
      @allNode[result.id] = result

      _.forEach tagArray, (tag) =>
        @addTag(result, tag)
      @storeTag()
    
  move: ->
  update: ->

  remove: (id) ->
    if _.isNumber(id)
      id = Util.numToString(id)

    bm = _.cloneDeep(@allNode[id])
    @lastDeletedNodeArray.unshift(bm)
    if @lastDeletedNodeArray.length > @MAX_RECOVER_NUM
      @lastDeletedNodeArray.pop()
    chrome.storage.sync.set({ lastDeletedNodeArray: @lastDeletedNodeArray })

    chrome.bookmarks.remove id, =>
      @delAssociatedTag({ id })
      delete @allNode[id]

      @cleanTag()
      @storeTag()

  recover: (indexOrIndexArray) ->
    if _.isNumber(indexOrIndexArray)
      index = indexOrIndexArray

      bm = @lastDeletedNodeArray[index]
      @create(Util.toSimpleBookmark(bm), bm.tagArray)
      @lastDeletedNodeArray = _.without(@lastDeletedNodeArray, bm)
      chrome.storage.sync.set({ lastDeletedNodeArray: @lastDeletedNodeArray })

    else
      indexArray = indexOrIndexArray

      bmArray = _.at(@lastDeletedNodeArray, indexArray)
      _.forEach bmArray, (bm) =>
        @create(Util.toSimpleBookmark(bm), bm.tagArray)

      @lastDeletedNodeArray = _.difference(@lastWindowTabArray, bmArray)
      chrome.storage.sync.set({ lastDeletedNodeArray: @lastDeletedNodeArray })

  # ------------------------------------------------------------
  # Bookmark operation end
  # ------------------------------------------------------------
