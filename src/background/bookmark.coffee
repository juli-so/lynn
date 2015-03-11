# ---------------------------------------------------------------------------- #
#                                                                              #
# Manage bookmarks                                                             #
#                                                                              #
# ---------------------------------------------------------------------------- #

Bookmark =
  # Only non-folder nodes
  allNode: {} # id -> Node
  # For each node there must be a tagArr associated with it
  allTag:  {} # id -> TagArr

  # ------------------------------------------------------------
  # Init
  # ------------------------------------------------------------

  init: ->
    # Recursively init all nodes
    initNode = (node) =>
      if node.url
        @allNode[node.id] = node
      else
        _.forEach(node.children, initNode)

    initTag = =>
      chrome.storage.local.get 'allTag', (storObj) =>
        @allTag = storObj.allTag || {}

        # Clean tagArr with no corresponding node
        _.forEach @allTag, (tagArr, id) =>
          if not @allNode[id]
            delete @allTag[id]

        _.forEach @allNode, (node) =>
          if @allTag[node.id]
            node.tagArr = @allTag[node.id]
          else
            node.tagArr = @allTag[node.id] = []

    chrome.bookmarks.getSubTree '1', (nodeArr) =>
      initNode(nodeArr[0])
      initTag()

  initLocal: (allNode) ->
    @allNode = allNode
    @allTag = {}
    _.forEach allNode, (node) =>
      if node.tagArr
        @allTag[node.id] = node.tagArr
      else
        @allTag[node.id] = node.tagArr = []

  # ------------------------------------------------------------
  # Tag
  # ------------------------------------------------------------

  storeTag: ->
    chrome.storage.local.set
      allTag: @allTag

  _pushTag: (id, tag) ->
    @allTag[id].push(tag)

  _pullTag: (id, tag) ->
    _.pull(@allTag[id], tag)

  # Only add valid, case-insensitive no dup tags
  addTag: (id, tag, update = yes) ->
    hasNode  = _.has(@allNode, id)
    tagValid = Util.isTag(tag)
    noDup    = _.all @allTag[id], (t) -> not _.ciEquals(t, tag)

    if hasNode and tagValid and noDup
      @_pushTag(id, tag)
      if update
        @storeTag()

  # Only delete if tag is valid and present
  # Case-insensitive. E.g: del '#ha' will delete '#HA'
  delTag: (id, tag, update = yes) ->
    hasNode = _.has(@allNode, id)
    tagValid = Util.isTag(tag)
    tagPresent = _.ciArrContains(@allTag[id], tag)

    if hasNode and tagValid and tagPresent
      # Find ciEqual tag to delete
      tagToDel = _.ciArrFind(@allTag[id], tag)
      @_pullTag(id, tagToDel)
      if update
        @storeTag()

  delAllTag: (id) ->
    _.clearArr(@allTag[id])
    @storeTag()
      
  # ------------------------------------------------------------
  # Search
  #
  # fb = find by
  #
  # * All find returns an object { nodeId: node }
  # ------------------------------------------------------------

  # To Node Object
  # Change nodeArr to { node.id: node } object to allow chaining
  _toNO: (nodeArr) ->
    _.zipObject(_.pluck(nodeArr, 'id'), nodeArr)

  fbTag: (tag, pool = @allNode) ->
    _.pick pool, (node, index) -> _.ciArrContains(node.tagArr, tag)

  fbTagArr: (tagArr, pool = @allNode) ->
    if _.isEmpty(tagArr)
      return pool

    if tagArr.length is 1
      @fbTag(tagArr[0], pool)
    else
      newPool = @fbTag(tagArr.shift(), pool)
      @fbTagArr(tagArr, newPool)

  # Find node that has at least one tag in tagArr
  fbTagRange: (tagArr, pool = @allNode) ->
    if _.isEmpty(tagArr)
      return pool

    nodeArr = _(tagArr)
                .map((tag) => _.values(@fbTag(tag, pool)))
                .flatten()
                .uniq()
                .value()

    @_toNO(nodeArr)

  fbTitle: (title, ci = yes, pool = @allNode) ->
    if ci
      _.pick pool, (node, index) -> _.ciContains(node.title, title)
    else
      _.pick pool, (node, index) -> _.contains(node.title, title)

  fbTitleArr: (titleArr, ci = yes, pool = @allNode) ->
    if _.isEmpty(titleArr)
      return pool

    if titleArr.length is 1
      @fbTitle(titleArr[0], ci, pool)
    else
      newPool = @fbTitle(titleArr.shift(), ci, pool)
      @fbTitleArr(titleArr, ci, newPool)

  fbURL: (url, ci = yes, pool = @allNode) ->
    if _.isEmpty(url)
      return pool

    if ci
      _.pick pool, (node, index) -> _.ciContains(node.url, url)
    else
      _.pick pool, (node, index) -> _.contains(node.url, url)

  fbExactURL: (url, pool = @allNode) ->
    if _.isEmpty(url)
      return pool

    _.pick pool, (node, index) -> _.isEqual(node.url, url)

  # ------------------------------------------------------------
  # Find by query
  # Return a ranked nodeArr
  # ------------------------------------------------------------

  _allUniqTag: ->
    _(@allTag).values()
              .flatten()
              .uniq()
              .value()

  _suggestTag: (tagFragment) ->
    return [] if Util.isntTag(tagFragment)

    _.filter @_allUniqTag(), (tag) ->
      _.ciContains(tag, tagFragment)

  find: (query, pool = @allNode) ->
    return [] if _.isEmpty(query)

    # When query is just '#' or '@'
    # Show all bookmarks with any of these kinds of tags
    if query is '#' or query is '@'
      prefix = query

      return _.filter pool, (node) ->
        _.any node.tagArr, (tag) ->
          _.startsWith(tag, prefix)

    # Process query and tokenize tag and keyword
    if query[0] is '!'
      strictSearch = yes
      query = query[1..]
    else
      strictSearch = false

    tokenArr = query.split(' ')
    kwArr  = []
    tagArr = []

    _.forEach tokenArr, (token) ->
      # Filter out single "#"
      if token isnt '#' and token isnt '@'
        if Util.isTag(token)
          tagArr.push(token)
        else
          kwArr.push(token)

    # Find all entries that has at least one suggested tag
    if not _.isEmpty(tagArr)
      suggestedTagArr = _.uniq(_.flatten(_.map(tagArr, @_suggestTag.bind(@))))

      return [] if _.isEmpty(suggestedTagArr)

      # Strict search:
      # Output bookmarks that contain all intersection tags
      if strictSearch
        intersection = _.intersection(tagArr, suggestedTagArr)
        diff = _.difference(suggestedTagArr, intersection)

        result = _.values(
          @fbTitleArr(kwArr, yes, @fbTagArr(intersection, @fbTagRange(diff)))
        )

        nodeLog(Rank.rankStrict(kwArr, intersection, diff, result))
      else
        result = _.values(
          @fbTitleArr(kwArr, yes, @fbTagRange(suggestedTagArr))
        )

    else
      result = _.values(@fbTitleArr(kwArr, yes, pool))

    Rank.rank(kwArr, tagArr, result)

  # ------------------------------------------------------------
  # Create / Remove / Recover
  # ------------------------------------------------------------

  create: (node, tagArr, parentId = '1') ->
    node = _.assign(node, { parentId })

    chrome.bookmarks.create node, (node) =>
      node.tagArr = @allTag[node.id] = tagArr
      @allNode[node.id] = node
      @storeTag()
    
  remove: (id) ->
    chrome.bookmarks.remove id, =>
      lastDeletedNodeArr = CStorage.getState('lastDeletedNodeArr')
      MAX_RECOVER_NUM    = CStorage.getOption('MAX_RECOVER_NUM')

      clone = _.cloneDeep(@allNode[id])
      lastDeletedNodeArr.unshift(clone)
      lastDeletedNodeArr = lastDeletedNodeArr[0...MAX_RECOVER_NUM]
      CStorage.setState({ lastDeletedNodeArr })

      delete @allNode[id]
      @delAllTag(id)

  # Recover deleted bookmarks
  recover: (indexOrIndexArr) ->
    lastDeletedNodeArr = CStorage.getState('lastDeletedNodeArr')

    if _.isNumber(indexOrIndexArr)
      index = indexOrIndexArr

      bm = lastDeletedNodeArr[index]
      @create(Util.toSimpleBookmark(bm), bm.tagArr)

      lastDeletedNodeArr = _.without(lastDeletedNodeArr, bm)

    else
      indexArr = indexOrIndexArr

      bmArr = _.at(lastDeletedNodeArr, indexArr)
      _.forEach bmArr, (bm) =>
        @create(Util.toSimpleBookmark(bm), bm.tagArr)

      lastDeletedNodeArr = _.difference(lastDeletedNodeArr, bmArr)

    CStorage.setState({ lastDeletedNodeArr })

  # ------------------------------------------------------------
  # Stats for options page
  # ------------------------------------------------------------

  stats: ->
    bmAmount      = _.keys(@allNode).length
    tagBmAmount   = (_.filter @allNode, (node) -> node.tagArr.length > 0).length
    noTagBmAmount = bmAmount - tagBmAmount
    tagPercent    = _.toTwoDec(tagBmAmount   / bmAmount * 100)
    noTagPercent  = _.toTwoDec(noTagBmAmount / bmAmount * 100)
    allNode       = @allNode
    fiveRandBm    = _.flatten(_.times 5, => _.randPopFromArr(_.values(@allNode)))

    { bmAmount, tagBmAmount, noTagBmAmount,
      tagPercent, noTagPercent,
      allNode,
      fiveRandBm }

  # ------------------------------------------------------------
  # Others
  # ------------------------------------------------------------

  # Make a nodeArr tagged by matching URL with stored bookmarks
  tagify: (nodeArr) ->
    allUrl = _.pluck(@allNode, 'url')

    _.map nodeArr, (node) =>
      node = Util.tabToNode(node)
      if node.url in allUrl
        node.tagArr = _.values(@fbURL(node.url))[0].tagArr
      node
