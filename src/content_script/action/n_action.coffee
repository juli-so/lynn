# Normal actions

N_Action =
  log: ->
    console.log @state

  # ------------------------------------------------------------
  # App-wise actions
  # ------------------------------------------------------------

  hide: (clearCache = yes) ->
    @setState { animation: 'fadeOutUp' }

    timeOutFunc = =>
      @setState { visible: no }
      @callAction('n_reset', clearCache)

    setTimeout(timeOutFunc, 200)

  show: ->
    @setState
      visible: yes
      animation: 'fadeInDown'

  toggle: ->
    if @state.visible
      @callAction('n_hide')
    else
      @callAction('n_show')

  # ------------------------------------------------------------

  reset: (clearCache = yes) ->
    @setState
      input: ''

      mode: 'query'
      specialMode: 'no'

      animation: 'fadeInDown'
      nodeAnimation: {}

      nodeArr: []
      selectedArr: []

      useSuggestedTag: yes

      currentNodeIndex: 0
      currentPageIndex: 0

    @callAction('n_clearCache') if clearCache

  clearInput: ->
    if @state.mode is 'query'
      @setState
        input: ''

        nodeArr: []
        selectedArr: []

        currentNodeIndex: 0
        currentPageIndex: 0
    else if @state.mode is 'fast'
      @setState { mode: 'query' }
      @callAction('n_clearInput')
    else
      @setState { input: ':' }

  # ------------------------------------------------------------

  nextMode: ->
    if @state.mode is 'query'
      @setState { mode: 'fast' }

    else if @state.mode is 'fast'
      @setState { mode: 'command' }

      if @state.cache.input is ''
        @callAction('n_storeCache')
        @setState { input: ':' }
      else
        @callAction('n_storeAndRecoverFromCache')

    else
      @setState { mode: 'query' }

      if @state.input is ':'
        @callAction('n_recoverFromCache')
        @callAction('n_clearCache')
      else
        @callAction('n_storeAndRecoverFromCache')

  prevMode: ->
    if @state.mode is 'fast'
      @setState { mode: 'query' }

    else if @state.mode is 'command'
      @setState { mode: 'fast' }

      if @state.input is ':'
        @callAction('n_recoverFromCache')
        @callAction('n_clearCache')
      else
        @callAction('n_storeAndRecoverFromCache')

    else
      @setState { mode: 'command' }

      if @state.cache.input is ''
        @callAction('n_storeCache')
        @setState { input: ':' }
      else
        @callAction('n_storeAndRecoverFromCache')

  goQueryMode: ->
    @setState
      input: ''
      mode: 'query'

  # ------------------------------------------------------------
  # Movements
  # ------------------------------------------------------------

  up: ->
    if @state.nodeArr.length is 0
      return

    MAX = @state.option.MAX_SUGGESTION_NUM
    if @state.currentNodeIndex is 0
      if @state.currentPageIndex is 0
        currentNodeFullIndex = @state.nodeArr.length - 1
        @setState
          currentNodeIndex:
            currentNodeFullIndex % MAX
          currentPageIndex:
            Math.floor( currentNodeFullIndex / MAX)
      else
        @callAction('n_pageUp')
        @setState { currentNodeIndex: MAX - 1 }
    else
      currentNodeIndex = @state.currentNodeIndex - 1
      @setState { currentNodeIndex }

  down: ->
    if @state.nodeArr.length is 0
      return

    MAX = @state.option.MAX_SUGGESTION_NUM
    if @getCurrentNodeFullIndex() is @state.nodeArr.length - 1
      @setState
        currentNodeIndex: 0
        currentPageIndex: 0
    else
      if @state.currentNodeIndex isnt MAX - 1
        @setState { currentNodeIndex: @state.currentNodeIndex + 1 }
      else
        @setState
          currentNodeIndex: 0
          currentPageIndex: @state.currentPageIndex + 1

  # ------------------------------------------------------------

  pageUp: ->
    if @state.currentPageIndex > 0
      @setState
        currentPageIndex: @state.currentPageIndex - 1
        currentNodeIndex: 0

  pageDown: ->
    currentPageLastNodeIndex =
      (@state.currentPageIndex + 1) * @state.option.MAX_SUGGESTION_NUM
    if currentPageLastNodeIndex < @state.nodeArr.length
      @setState
        currentPageIndex: @state.currentPageIndex + 1
        currentNodeIndex: 0
      
  # ------------------------------------------------------------
  # Selection
  # ------------------------------------------------------------

  select: ->
    unless _.contains(@state.selectedArr, @getCurrentNodeFullIndex())
      selectedArr =
        _.union(@state.selectedArr, [@getCurrentNodeFullIndex()])
      @setState { selectedArr }

  unselect: ->
    if _.contains(@state.selectedArr, @getCurrentNodeFullIndex())
      selectedArr =
        _.without(@state.selectedArr, @getCurrentNodeFullIndex())
      @setState { selectedArr }

  # ------------------------------------------------------------

  selectAllInCurrentPage: ->
    newlySelected = [@getNodeIndexStart()...@getNodeIndexEnd()]
    selectedArr = _.union(@state.selectedArr, newlySelected)
    @setState { selectedArr }

  selectAll: ->
    @setState { selectedArr: [0...@state.nodeArr.length] }

  unselectAllInCurrentPage: ->
    newlyUnselected = [@getNodeIndexStart()...@getNodeIndexEnd()]
    selectedArr = _.difference(@state.selectedArr, newlyUnselected)
    @setState { selectedArr }

  unselectAll: ->
    @setState { selectedArr: [] }

  toggleAllSelectionInCurrentPage: ->
    currentPageNodeIndexArr = []
    if _.every([@getNodeIndexStart()...@getNodeIndexEnd()],
        (index) => _.contains(@state.selectedArr, index))
      @callAction('n_unselectAllInCurrentPage')
    else
      @callAction('n_selectAllInCurrentPage')

  toggleAll: ->
    if @state.selectedArr.length is @state.nodeArr.length
      @callAction('n_unselectAll')
    else
      @callAction('n_selectAll')

  # ------------------------------------------------------------
  # Insertion
  # ------------------------------------------------------------

  insert: ->
    @setState
      mode: 'query'

  insertBefore: ->
    @setState
      mode: 'query'
    @callAction('n_setCaretToStart')

  # ------------------------------------------------------------
  # Opening bookmarks
  # ------------------------------------------------------------
  
  openHelper: (option, newWin, needHide, nodeArr = null) ->
    message =
      req: if newWin then 'openInNewWin' else 'open'
      option: option

    if _.isNull(nodeArr)
      if @hasNoSelection()
        message['node'] = @getCurrentNode()
      else
        message['nodeArr'] = @getSelectedNodeArr()
    else
      message['nodeArr'] = nodeArr

    Message.postMessage(message)

    if needHide
      @callAction('n_hide')
    else
      @setState { selectedArr: [] }

  open: ->
    @callAction('n_openHelper', [{ active:    yes }, no , yes])

  openInBackground: ->
    @callAction('n_openHelper', [{ active:    no  }, no , no ])

  openInNewWin: ->
    @callAction('n_openHelper', [{ incognito: no  }, yes, yes])

  openInNewIncognitoWin: ->
    @callAction('n_openHelper', [{ incognito: yes }, yes, yes])

  # ------------------------------------------------------------
  # Remove bookmarks
  # ------------------------------------------------------------
    
  remove: ->
    if @state.nodeArr.length isnt 0
      nodeArr = @state.nodeArr
      selectedArr = @state.selectedArr
      MAX = @state.option.MAX_SUGGESTION_NUM

      if @hasNoSelection()
        # index within all nodeArr, not within current page nodes
        currentNodeFullIndex = @getCurrentNodeFullIndex()
        nodeAnimation = {}
        nodeAnimation[currentNodeFullIndex] = 'fadeOutRight'
        @setState { nodeAnimation }

        # Remove the bookmark in DB
        Message.postMessage
          req: 'removeBookmark'
          id: @getCurrentNode().id

        # Remove bookmark from screen using animation
        timeOutFunc = =>
          nodeArr = _.without(nodeArr, nodeArr[currentNodeFullIndex])

          # if the current selected node is the last one
          # let it still point to the last node after one node is removed
          if currentNodeFullIndex is nodeArr.length
            if @state.currentNodeIndex is 0
              currentNodeIndex = MAX - 1
              currentPageIndex = @state.currentPageIndex - 1
            else
              currentNodeIndex = @state.currentNodeIndex - 1
              currentPageIndex = @state.currentPageIndex

            @setState
              nodeArr: nodeArr
              nodeAnimation: {}

              currentNodeIndex: currentNodeIndex
              currentPageIndex: currentPageIndex
          else
            @setState
              nodeArr: nodeArr
              nodeAnimation: {}

          # Return to query mode if there is no search results 
          @setState({ mode: 'query' }) if _.isEmpty(@state.nodeArr)

        setTimeout(timeOutFunc, 350)

      else # HasSelection
        nodeAnimation = {}
        _.forEach selectedArr, (nodeIndex) ->
          nodeAnimation[nodeIndex] = 'fadeOutRight'
        @setState { nodeAnimation }

        # Remove the bookmark in DB
        idArr = _.pluck(_.at(nodeArr, selectedArr), 'id')
        Message.postMessage
          req: 'removeBookmark'
          idArr: idArr

        # Remove the bookmark from screen using animation
        timeOutFunc = =>
          leftNodeIndexArr =
            _.difference([0...nodeArr.length], selectedArr)
          leftNodeArr = _.at(nodeArr, leftNodeIndexArr)

          # Push node index back by the number of selected nodes before it
          currentNodeFullIndex = @getCurrentNodeFullIndex()
          nodeBeforeCurrent = _.filter selectedArr, (nodeIndex) ->
            nodeIndex < currentNodeFullIndex

          futureIndex = currentNodeFullIndex - nodeBeforeCurrent.length
          futureIndex = 0 if futureIndex < 0

          futureNodeIndex = futureIndex % MAX
          futurePageIndex = Math.floor(futureIndex / MAX)

          @setState
            nodeArr: leftNodeArr
            selectedArr: []

            nodeAnimation: {}

            currentNodeIndex: futureNodeIndex
            currentPageIndex: futurePageIndex

          # Return to query mode if there is no search results 
          @setState({ mode: 'query' }) if _.isEmpty(@state.nodeArr)

        setTimeout(timeOutFunc, 350)

  # ------------------------------------------------------------
  # Cache
  # ------------------------------------------------------------

  storeCache: (cache) ->
    if cache
      @setState { cache }
    else
      @setDeepState
        cache:
          input: @state.input
          nodeArr: _.cloneDeep(@state.nodeArr)
          selectedArr: @state.selectedArr

  clearCache: ->
    @setState
      cache:
        input: ''
        nodeArr: []
        selectedArr: []

  recoverFromCache: (cache) ->
    if cache
      @setState
        input: cache.input
        nodeArr: cache.nodeArr
        selectedArr: cache.selectedArr
    else
      @setState
        input: @state.cache.input
        nodeArr: @state.cache.nodeArr
        selectedArr: @state.cache.selectedArr

  # Recover from the current cache, but store current state in cache
  # before recovering
  storeAndRecoverFromCache: ->
    currentCache = _.cloneDeep(@state.cache)
    @callAction('n_storeCache')
    @callAction('n_recoverFromCache', [currentCache])

  # ------------------------------------------------------------
  # Caret movement and word processing
  # ------------------------------------------------------------

  setCaretToStart: ->
    if @state.mode is 'query'
      Util.setCaretRange(0, 0)
    else
      if @state.specialMode isnt 'no'
        Util.setCaretRange(0, 0)
      else
        Util.setCaretRange(1, 1)
    
  setCaretToEnd: ->
    Util.setCaretRange(@state.input.length, @state.input.length)

  setCaretToPrevWord: ->
    input = @state.input
    [start, end] = Util.getCaretPosition()
    
    beforeCaret = input[0...start]
    afterCaret = input[start...]

    beforeCaretArr = beforeCaret.split(' ')

    spaceTokenNum = (_.last beforeCaretArr, (s) ->
      s is ""
    ).length

    leftTokenSize = Math.max(0, beforeCaretArr.length - spaceTokenNum - 1)
    position = beforeCaretArr[0...leftTokenSize].join(' ').length

    Util.setCaretRange(position, position)
    
  setCaretToNextWord: ->
    input = @state.input
    [start, end] = Util.getCaretPosition()

    beforeCaret = input[0...start]
    afterCaret = input[start...]

    afterCaretArr = afterCaret.split(' ')

    spaceTokenNum = (_.first afterCaretArr, (s) ->
      s is ""
    ).length

    position = beforeCaret.length +
      afterCaretArr[0...spaceTokenNum + 1].join(' ').length

    Util.setCaretRange(position, position)

  deletePrevWord: ->
    input = @state.input
    [start, end] = Util.getCaretPosition()
    
    beforeCaret = input[0...start]
    afterCaret = input[start...]

    beforeCaretArr = beforeCaret.split(' ')

    spaceTokenNum = (_.last beforeCaretArr, (s) ->
      s is ""
    ).length

    leftTokenSize = Math.max(0, beforeCaretArr.length - spaceTokenNum - 1)
    input = beforeCaretArr[0...leftTokenSize].join(' ') + afterCaret
    position = beforeCaretArr[0...leftTokenSize].join(' ').length

    @setState { input }
    Util.setCaretRange(position, position)

  deleteNextWord: ->
    input = @state.input
    [start, end] = Util.getCaretPosition()

    beforeCaret = input[0...start]
    afterCaret = input[start...]

    afterCaretArr = afterCaret.split(' ')

    spaceTokenNum = (_.first afterCaretArr, (s) ->
      s is ""
    ).length

    console.log afterCaretArr
    console.log spaceTokenNum
    input = beforeCaret + afterCaretArr[spaceTokenNum + 1...].join(' ')

    @setState { input }
    Util.setCaretRange(start, start)

  # ------------------------------------------------------------
  # Session
  # ------------------------------------------------------------

  openSession: (command, modifierString) ->
    sessionRecord = @state.sessionMap[command]

    if sessionRecord.type is 'window'
      nodeArr = sessionRecord.session
      
      openArgs = switch modifierString
        when ''       then [{ active:    yes }, no , yes, nodeArr]
        when 's-'     then [{ active:    no  }, no , no , nodeArr]
        when 'c-'     then [{ incognito: no  }, yes, yes, nodeArr]
        when 'c-s-'   then [{ incognito: yes }, yes, yes, nodeArr]

      @callAction('n_openHelper', openArgs)
    else
      _.forEach sessionRecord.session, (nodeArr) =>
        openArgs = switch modifierString
          when ''       then [{ active:    yes }, no , yes, nodeArr]
          when 's-'     then [{ active:    no  }, no , no , nodeArr]
          when 'c-'     then [{ incognito: no  }, yes, yes, nodeArr]
          when 'c-s-'   then [{ incognito: yes }, yes, yes, nodeArr]

        @callAction('n_openHelper', openArgs)

