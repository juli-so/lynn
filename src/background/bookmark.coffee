##############################################################################
#
#  Bookmark manager functionality
#    -> Manage tags
#      * Check, retrieve, add, remove, replace tags of Node
#      * Sync to/from storage
#    -> Manage bookmarks
#      * Get, create, move, update, remove Node
#    -> Main functionality
#      * Retrieve Node from Chrome
#      * Search for Node with different criteria
#      
##############################################################################
#  
#  ! Node refers to chrome.bookmarks.BookmarkTreeNode
#    Node = Bookmark | Directory
#  ! Storage refers to chrome.storage.local, may change in future
#
##############################################################################

Bookmark =
  # id = Node.id
  #
  # { id: Node }
  # allNode = allBookmark + allDirectory
  # Some filter function use 'nodeType' as an argument, which could be
  #   'N' -> Node
  #   'B' -> Bookmark
  #   'D' -> Directory
  allNode: {}
  allBookmark: {}
  allDirectory: {}
  # { id: [tag] }
  linkedTag: {}
  # { tag: [id] }
  linkedID: {}

  # ==========================================================================
  #
  #  Tag
  #    * Tags are plain strings, but empty string is not allowed
  #    * Each Node is associated with an array of unique tags
  #    * Change of tags are reflected in storage immediately, since i/o on 
  #      storage is cheap
  #    
  # ==========================================================================

  hasTag: (nodeOrNodeArray, tag) ->
    if _.isArray(nodeOrNodeArray)
      _.every(nodeOrNodeArray, ((node) -> @hasTag(node, tag)), @)
    else
      node = nodeOrNodeArray
      @linkedTag[node.id] and _.contains(@linkedTag[node.id], tag)

  getTagArray: (nodeOrNodeArray) ->
    @linkedTag[node.id] or []

  # For one node, return true if one operation is successful
  # For nodeArray, return true only if every operation is successful
  addTag: (nodeOrNodeArray, tag) ->
    if tag == ''
      false
    if _.isArray(nodeOrNodeArray)
      result = yes
      _.forEach(nodeOrNodeArray, ((node) ->
        unless @addTag(node, tag)
          result = no
      ), @)
      result
    else
      node = nodeOrNodeArray
      if @hasTag(node, tag)
        false
      else
        if not @linkedTag[node.id]
          @linkedTag[node.id] = []
        @linkedTag[node.id].push(tag)

        if not @linkedID[tag]
          @linkedID[tag] = []
        @linkedID[tag].push(node.id)
        true

  delTag: (nodeOrNodeArray, tag) ->
    if _.isArray(nodeOrNodeArray)
      result = yes
      _.forEach(nodeOrNodeArray, ((node) ->
        unless @delTag(node, tag)
          result = no
      ), @)
      result
    else
      node = nodeOrNodeArray
      if @hasTag(node, tag)
        _.pull(@linkedTag[node.id], tag)
        _.pull(@linkedID[tag], node.id)
        true
      else
        false

  replaceTag: (nodeOrNodeArray, oldTag, newTag) ->
    if _.isArray(nodeOrNodeArray)
      result = yes
      _.forEach(nodeOrNodeArray, ((node) ->
        unless @replaceTag(node, oldTag, newTag)
          result = no
      ), @)
      result
    else
      node = nodeOrNodeArray
      if @delTag(node, oldTag)
        @addTag(node, newTag)
        true
      else
        false

  # ==========================================================================
  #
  #  Node
  #    * Functions with side effect change allNode immediately, but the real 
  #      effect on chrome.bookmarks is asynchronous
  #
  # ==========================================================================

  getID: (nodeOrNodeArray) ->
    if _.isArray(nodeOrNodeArray)
      _.map(nodeOrNodeArray, ((node) -> @getID(node)), @)
    else
      nodeOrNodeArray.id

  getNode: (idOrIDArray) ->
    if _.isArray(idOrIDArray)
      _.map(idOrIDArray, ((id) -> @getNode(id)), @)
    else
      @allNode[idOrIDArray]

  getBookmark: (idOrIDArray) ->
    if _.isArray(idOrIDArray)
      _.map(idOrIDArray, ((id) -> @getBookmark(id)), @)
    else
      @allBookmark[idOrIDArray]

  getDirectory: (idOrIDArray) ->
    if _.isArray(idOrIDArray)
      _.map(idOrIDArray, ((id) -> @getDirectory(id)), @)
    else
      @allDirectory[idOrIDArray]

  nodeIsBookmark: (node) ->
    node.url?

  # node object
  # {
  #   (opt)parentId,
  #   (opt)index,
  #   (opt)title,
  #   (opt)url
  # }
  createNode: (node, callback = _.noop) ->
    chrome.bookmarks.create(node, callback)

  # destination object
  # {
  #   (opt)parentId,
  #   (opt)index
  # }
  moveNode: (id, destination, callback = _.noop) ->
    chrome.bookmarks.move(id, destination, callback)
    
  # changes object
  # {
  #   (opt)title,
  #   (opt)url
  # }
  updateNode: (id, changes, callback = _.noop) ->
    chrome.bookmarks.update(id, changes, callback)

  removeNode: (id, callback = _.noop) ->
    if @nodeIsBookmark(@getNode(id))
      chrome.bookmarks.remove(id, callback)
    else
      chrome.bookmarks.removeTree(id, callback)

  # ==========================================================================
  #
  #  Main functionality
  #
  # ==========================================================================

  # Retrieve Node from chrome and tags from storage
  # !!!
  # A 'tagArray' property is added to node for ease of operation on node 
  # node.tagArray = linkedTag[node.id] or []
  # !!!
  init: (callback = _.noop) ->
    initNode = ((node) ->
      @allNode[node.id] = node

      if @nodeIsBookmark(node)
        @allBookmark[node.id] = node
      else
        @allDirectory[node.id] = node
        _.forEach(node.children, initNode, @)
    ).bind(@)

    initTag = (->
      chrome.storage.local.get(['linkedTag', 'linkedID'], ((storageObject) ->
        @linkedTag = storageObject['linkedTag']
        @linkedID = storageObject['linkedID']
        _.forEach(@allNode, ((node) ->
          if @linkedTag[node.id]
            node.tagArray = @linkedTag[node.id]
          else
            node.tagArray = @linkedTag[node.id] = []
        ).bind(@))

        callback()

      ).bind(@))
    ).bind(@)

    chrome.bookmarks.getTree((nodeArray) ->
      initNode(nodeArray[0])
      initTag()
    )



  storeTag: ->
    chrome.storage.local.set({
      'linkedTag': @linkedTag,
      'linkedID': @linkedID
    })

  # When nodeType is B | D, custom pool will be ignored
  # When nodeType is N, custom pool can be passed in
  # This allows chained filtering
  filter: (f, nodeType = 'N', pool = @allNode) ->
    if nodeType == 'B'
      pool = @allBookmark
    if nodeType == 'D'
      pool = @allDirectory

    result = []
    _.forEach(pool, (node) ->
      result.push(node) if f(node)
    )
    result
    
  # 
  # All following functions starting with 'find' return Array of Node
  #
  findByTag: (tagArray, nodeType = 'N', pool = @allNode) ->
    if pool == @allNode
      matchedNodeID = _(tagArray)
        .map(((tag) -> @linkedID[tag]), @)
        .compact()
        .reduce((prev, next) -> _.intersection(prev, next))
    else
      poolIDArray = _.map(pool, (node) -> node.id)
      matchedNodeID = _(tagArray)
        .map(((tag) -> @linkedID[tag]), @)
        .compact()
        .reduce(((prev, next) -> _.intersection(prev, next)), poolIDArray)

    if nodeType == 'B'
      @getBookmark(matchedNodeID)
    else if nodeType == 'D'
      @getDirectory(matchedNodeID)
    else
      @getNode(matchedNodeID)

  findByTitleContains: (fragmentArray, nodeType = 'N', isCaseSensitive = no, pool = @allNode) ->
    if isCaseSensitive
      filterFunc = (node) ->
        _.every(fragmentArray, (fragment) ->
          _.contains(node.title, fragment)
        )
    else
      filterFunc = (node) ->
        _.every(fragmentArray, (fragment) ->
          Util.ciContains(node.title, fragment)
        )
    @filter(filterFunc, nodeType, pool)

  # No nodeType since only Bookmark has URL
  findByURLContains: (fragment, isCaseSensitive = no, pool = @allBookmark) ->
    # Use N as nodetype so custom pool can be passed
    # Still searches for Bookmark by default
    if isCaseSensitive
      @filter(((node) -> _.contains(node.url, fragment)), 'N', pool)
    else
      @filter(((node) -> Util.ciContains(node.url, fragment)), 'N', pool)

  find: (query) ->
    return [] if _.isEmpty(query)
    
    tokenArray = query.split(' ')
    keywordArray = []
    tagArray = []

    _.forEach(tokenArray, (token) ->
      if token[0] == '#'
        tagArray.push(token.slice(1))
      else if token[0] == '@'
        tagArray.push(token)
      else
        keywordArray.push(token)
    )

    @findByTag(tagArray, 'N', @findByTitleContains(keywordArray))

