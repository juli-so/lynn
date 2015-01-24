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

        _.forEach @allNode, (node) =>
          if @allTag[node.id]
            node.tagArr = @allTag[node.id]
          else
            node.tagArr = @allTag[node.id] = []

    chrome.bookmarks.getSubTree '1', (nodeArr) =>
      initNode(nodeArr[0])
      initTag()

  # ------------------------------------------------------------
  # Tag
  # ------------------------------------------------------------

  _pushTag: (id, tag) ->
    @allTag[id].push(tag)

  _pullTag: (id, tag) ->
    _.pull(@allTag[id], tag)

  # Only add valid, case-insensitive no dup tags
  addTag: (id, tag) ->
    hasNode  = _.has(@allNode, id)
    tagValid = Util.isTag(tag)
    noDup    = _.all @allTag[id], (t) -> not _.ciEquals(t, tag)

    if hasNode and tagValid and noDup
      @_pushTag(id, tag)

  # Only delete if tag is valid and present
  # Case-insensitive. E.g: del '#ha' will delete '#HA'
  delTag: (id, tag) ->
    hasNode = _.has(@allNode, id)
    tagValid = Util.isTag(tag)
    tagPresent = _.ciArrContains(@allTag[id], tag)

    if hasNode and tagValid and tagPresent
      # Find ciEqual tag to delete
      tagToDel = _.ciArrFind(@allTag[id], tag)
      @_pullTag(id, tagToDel)
      
  # ------------------------------------------------------------
  # Search
  #
  # fb: find by
  #
  # * All find returns an object { nodeId: node }
  # ------------------------------------------------------------

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
      @fbTitleArr(titleArr, newPool)

  find: (query, pool = @allNode) ->
    return [] if _.isEmpty(query)

    # When query is just '#' or '@'
    # Show all bookmarks with any of these kinds of tags
    if query is '#' or query is '@'
      prefix = query

      _.pick pool, (node) ->
        _.any node.tagArr, (tag) ->
          _.startsWith(tag, prefix)

    # Process query and tokenize tag and keyword
    else
      tokenArr = query.split(' ')
      kwArr  = []
      tagArr = []

      _.forEach tokenArr, (token) ->
        if Util.isTag(token)
          tagArr.push(token)
        else
          kwArr.push(token)

      @fbTitleArr(kwArr, yes, @fbTagArr(tagArr))
