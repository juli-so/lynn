Bookmark =
  allNode: {} # id -> Node

  nodeTagMap: {} # Node.id -> Node.tagArr
  tagNodeMap: {} # tag -> [Node.id]

  # Synced to storage.sync
  lastAddedNodeArr: []
  lastDeletedNodeArr: []

  # Options
  MAX_RECOVER_NUM: 10
  MAX_LASTADD_NUM: 10

  synoTagRecordArr: []

  # ------------------------------------------------------------
  # Init
  # ------------------------------------------------------------

  # Does not include directories
  init: (callback = _.noop) ->
    initNode = (node) =>
      if node.url
        @allNode[node.id] = node
      else
        _.forEach(node.children, initNode)

    initTag = =>
      chrome.storage.local.get ['nodeTagMap', 'tagNodeMap'],
        (storObj) =>
          @nodeTagMap = storObj['nodeTagMap'] || {}
          @tagNodeMap = storObj['tagNodeMap'] || {}

          _.forEach @allNode, (node) =>
            if @nodeTagMap[node.id]
              node.tagArr = @nodeTagMap[node.id]
            else
              node.tagArr = @nodeTagMap[node.id] = []

          # initNode only contains synchronous calls but initTag has async calls
          # Put callback here to ensure it happens after all initiation
          callback()

    initOther = =>
      chrome.storage.sync.get null, (storObj) =>
        @lastAddedNodeArr =
          storObj.lastAddedNodeArr || @lastDeletedNodeArr
        @lastDeletedNodeArr =
          storObj.lastDeletedNodeArr || @lastDeletedNodeArr
        @MAX_RECOVER_NUM =
          storObj.MAX_RECOVER_NUM || @MAX_RECOVER_NUM
        @synoTagRecordArr =
          storObj.synoTagRecordArr || @synoTagRecordArr

    # '1' for 'Bookmarks Bar' in chrome by default
    # Later might let user specify root
    chrome.bookmarks.getSubTree '1', (nodeArr) ->
      initNode(nodeArr[0])
      initTag()
      initOther()

  # ------------------------------------------------------------
  # Tag operation
  # ------------------------------------------------------------

  isTag: (tag) ->
    tag[0] is '#' or tag[0] is '@'

  isntTag: (tag) ->
    not @isTag(tag)
  
  addTag: (node, tag) ->
    return false if @isntTag(tag)

    # In case the node is sent from front end
    node = @allNode[node.id]

    if _.contains(node.tagArr, tag)
      false
    else
      node.tagArr.push(tag)
      @tagNodeMap[tag] or= []
      @tagNodeMap[tag].push(node.id)
      true

  delTag: (node, tag) ->
    return false if @isntTag(tag)

    # In case the node is sent from front end
    node = @allNode[node.id]

    if _.contains(node.tagArr, tag)
      _.pull(node.tagArr, tag)
      _.pull(@tagNodeMap[tag], node.id)
      true
    else
      false

  # When removing a bookmark
  # All its tags should also be removed
  delAllTag: (node) ->
    # In case the node is sent from front end
    node = @allNode[node.id]

    _.forEach node.tagArr, (tag) =>
      _.pull(@tagNodeMap[tag], '' + node.id)
    _.remove(node.tagArr)

  # Remove meaningless entries in nodeTagMap and tagNodeMap
  pruneTag: ->
    _.forEach @nodeTagMap, (tagArr, index) =>
      delete @nodeTagMap[index] unless @allNode[index]

    @tagNodeMap = {}

    _.forEach @allNode, (node) =>
      _.forEach node.tagArr, (tag) =>
        @tagNodeMap[tag] = [] unless @tagNodeMap[tag]
        @tagNodeMap[tag].unshift(node.id)

    chrome.storage.local.set({ tagNodeMap: @tagNodeMap })

  storeTag: ->
    chrome.storage.local.set
      nodeTagMap: @nodeTagMap
      tagNodeMap: @tagNodeMap

  resetTag: ->
    chrome.storage.local.set
      nodeTagMap: []
      tagNodeMap: []

  # ------------------------------------------------------------
  # Find and Filter
  # ------------------------------------------------------------

  # To Node Object
  # Change nodeArr to { node.id: node } object to allow chaining
  _toNO: (nodeArr) ->
    _.zipObject(_.pluck(nodeArr, 'id'), nodeArr)

  # ------------------------------------------------------------

  findByTag: (tag, pool = @allNode) ->
    matchedTagArr = _.filter Object.keys(@tagNodeMap), (t) ->
      t.toLowerCase() is tag.toLowerCase()

    idList = _(matchedTagArr)
               .map((matchedTag) => @tagNodeMap[matchedTag])
               .flatten()
               .uniq()
               .value()

    _.compact(_.at(pool, idList))

  # Find node that has ALL the tags in tagArr
  findByTagArr: (tagArr, pool = @allNode) ->
    if _.isEmpty(tagArr)
      result = pool
    else
      reduceFunc = (accumulator, tag) =>
        @_toNO(@findByTag(tag, accumulator))

      result = _.reduce(tagArr, reduceFunc, pool)

    _.toArray(result)

  # Find node that has AT LEAST ONE tag in tagArr
  findByTagRange: (tagArr, pool = @allNode) ->
    if _.isEmpty(tagArr)
      result = pool
    else
      result = {}
      _.forEach tagArr, (tag) =>
        result = _.defaults(result, @_toNO(@findByTag(tag, pool)))

    _.toArray(result)

  findByTitle: (fragment, isCaseSensitive = no, pool = @allNode) ->
    if isCaseSensitive
      _.filter pool, (node) ->
        _.contains(node.title, fragment)
    else
      _.filter pool, (node) =>
        Util.ciContains(node.title, fragment)

  # Find node that has ALL fragments in fragmentArr
  findByTitleArr: (fragmentArr, isCaseSensitive = no, pool = @allNode) ->
    if _.isEmpty(fragmentArr)
      result = pool
    else
      reduceFunc = (accumulator, fragment) =>
        @_toNO(@findByTitle(fragment, isCaseSensitive, accumulator))

      result = _.reduce(fragmentArr, reduceFunc, pool)

    _.toArray(result)

  # Find node that has AT LEAST ONE fragment
  findByTitleRange: (fragmentArr, isCaseSensitive = no, pool = @allNode) ->
    if _.isEmpty(fragmentArr)
      result = pool
    else
      result = {}
      _.forEach fragmentArr, (fragment) =>
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

  # Suggest a tagArr from the tagFragment
  # SynoTag matches are also included
  _suggestTag: (tagFragment) ->
    return [] if @isntTag(tagFragment)

    allTagName = Object.keys(@tagNodeMap)

    suggestedTagArr = _.filter allTagName, (tag) =>
      Util.ciContains(tag, tagFragment)

    # Synotag processing
    # If found a match with a dominant tag, use that tag
    # Else put all SynoTags into the array
    _findSynoMatch = (tag) =>
      _.find @synoTagRecordArr, (synoTagRecord) ->
        _.any synoTagRecord.memberArr, (member) ->
          _.ciContains(member, tag)

    matchRecord = _findSynoMatch(tagFragment)
    synoTagSuggestedTagArr = []
    if matchRecord
      if matchRecord.dominant
        synoTagSuggestedTagArr.push(matchRecord.dominant)
      else
        _.forEach matchRecord.memberArr, (member) ->
          synoTagSuggestedTagArr.push(member)

    _.uniq(suggestedTagArr.concat(synoTagSuggestedTagArr))


  find: (query, pool = @allNode) ->
    # Special cases
    return [] if _.isEmpty(query)

    if query is '#l' and not @tagNodeMap['#l'] or
       query is '#last'
      return @lastAddedNodeArr

    # When query is just '#' or '@'
    # Show all bookmarks with any of these kinds of tags
    if query is '#' or query is '@'
      prefix = query
      tagRange = _.filter Object.keys(@tagNodeMap), (tag) ->
        Util.startsWith(tag, prefix)
      return @findByTagRange(tagRange)

    # Process query and tokenize tag and keyword
    tokenArr = query.split(' ')
    keywordArr = []
    tagArr = []

    _.forEach tokenArr, (token) =>
      if @isTag(token)
        tagArr.push(token)
      else
        keywordArr.push(token)

    # Search with Tag
    if not _.isEmpty(tagArr)
      suggestedTagArr = _(tagArr)
                          .map((tag) => @_suggestTag(tag))
                          .flatten()
                          .uniq()
                          .value()

      return [] if _.isEmpty(suggestedTagArr)

      log 'In find'
      log suggestedTagArr

      pool = @_toNO(@findByTagRange(suggestedTagArr))
      return [] if _.isEmpty(pool)

    # Filter with Keyword
    @findByTitleArr(keywordArr, no, pool)

  # ------------------------------------------------------------
  # Bookmark operation
  # ------------------------------------------------------------

  # Do not care who (user or by import) created it
  # Just add node & tag locally and update lastAdded list
  _h_create: (node, tagArr) ->
    node.tagArr = @nodeTagMap[node.id] = []
    @allNode[node.id] = node

    _.forEach tagArr, (tag) =>
      @addTag(node, tag)
    @storeTag()

    bmCopy = _.cloneDeep(@allNode[node.id])

    # Handle lastAdded
    @lastAddedNodeArr.unshift(bmCopy)
    while @lastAddedNodeArr.length > @MAX_LAST_ADD_NUM
      @lastAddedNodeArr.pop()
    chrome.storage.sync.set({ lastAddedNodeArr: @lastAddedNodeArr })
    
  createLocal: (id, tagArr) ->
    chrome.bookmarks.get id, (storObj) =>
      node = storObj[0]

      @_h_create(node, tagArr)

  create: (node, tagArr) ->
    node = _.assign(node, { parentId: '232' })

    chrome.bookmarks.create node, (node) =>
      @_h_create(node, tagArr)
    
  # ------------------------------------------------------------

  _h_remove: (id, localOnly) ->
    if _.isNumber(id)
      id = Util.numToString(id)

    bm = _.cloneDeep(@allNode[id])
    @lastDeletedNodeArr.unshift(bm)
    while @lastDeletedNodeArr.length > @MAX_RECOVER_NUM
      @lastDeletedNodeArr.pop()
    chrome.storage.sync.set({ lastDeletedNodeArr: @lastDeletedNodeArr })

    unless localOnly
      chrome.bookmarks.remove id, =>
        _.forEach @allNode[id].tagArr, (tag) =>

        @delAllTag({ id })
        delete @allNode[id]

        @storeTag()

  removeLocal: (id) -> @_h_remove(id, yes)
  remove:      (id) -> @_h_remove(id, no )

  # ------------------------------------------------------------

  recover: (indexOrIndexArr) ->
    if _.isNumber(indexOrIndexArr)
      index = indexOrIndexArr

      bm = @lastDeletedNodeArr[index]
      @create(Util.toSimpleBookmark(bm), bm.tagArr)
      @lastDeletedNodeArr = _.without(@lastDeletedNodeArr, bm)
      chrome.storage.sync.set({ lastDeletedNodeArr: @lastDeletedNodeArr })

    else
      indexArr = indexOrIndexArr

      bmArr = _.at(@lastDeletedNodeArr, indexArr)
      _.forEach bmArr, (bm) =>
        @create(Util.toSimpleBookmark(bm), bm.tagArr)

      @lastDeletedNodeArr = _.difference(@lastDeletedNodeArr, bmArr)
      chrome.storage.sync.set({ lastDeletedNodeArr: @lastDeletedNodeArr })
