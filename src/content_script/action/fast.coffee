FastAction =
  select: ->
    unless _.contains(@state.selectedArray, @getCurrentNodeFullIndex())
      selectedArray =
        _.union(@state.selectedArray, [@getCurrentNodeFullIndex()])
      @setState { selectedArray }

  unselect: ->
    if _.contains(@state.selectedArray, @getCurrentNodeFullIndex())
      selectedArray =
        _.without(@state.selectedArray, @getCurrentNodeFullIndex())
      @setState { selectedArray }

  # ------------------------------------------------------------

  selectAllInCurrentPage: ->
    newlySelected = [@getNodeIndexStart()...@getNodeIndexEnd()]
    selectedArray = _.union(@state.selectedArray, newlySelected)
    @setState { selectedArray }

  selectAll: ->
    @setState { selectedArray: [0...@state.nodeArray.length] }

  unselectAllInCurrentPage: ->
    newlyUnselected = [@getNodeIndexStart()...@getNodeIndexEnd()]
    selectedArray = _.difference(@state.selectedArray, newlyUnselected)
    @setState { selectedArray }

  unselectAll: ->
    @setState { selectedArray: [] }

  toggleAllSelectionInCurrentPage: ->
    currentPageNodeIndexArray = []
    if _.every([@getNodeIndexStart()...@getNodeIndexEnd()],
        (index) => _.contains(@state.selectedArray, index))
      @callAction('f_unselectAllInCurrentPage')
    else
      @callAction('f_selectAllInCurrentPage')

  toggleAll: ->
    if @state.selectedArray.length is @state.nodeArray.length
      @callAction('f_unselectAll')
    else
      @callAction('f_selectAll')

  # ------------------------------------------------------------

  tag: ->
    @setState
      specialMode: 'tag'
      input: ''

  # ------------------------------------------------------------

  remove: ->
    if @state.nodeArray.length isnt 0
      # index within all nodeArray, not within current page nodes
      currentNodeFullIndex = @getCurrentNodeFullIndex()
      nodeAnimation = {}
      nodeAnimation[currentNodeFullIndex] = 'fadeOutRight'
      @setState { nodeAnimation }

      # remove bookmark from screen using animation
      timeOutFunc = =>
        nodeArray = @state.nodeArray
        nodeArray = _.without(nodeArray, nodeArray[currentNodeFullIndex])

        # if the current selected node is the last one
        # let it still point to the last node after one node is removed
        if currentNodeFullIndex is nodeArray.length
          if @state.currentNodeIndex is 0
            currentNodeIndex = @state.option.MAX_SUGGESTION_NUM - 1
            currentPageIndex = @state.currentPageIndex - 1
          else
            currentNodeIndex = @state.currentNodeIndex - 1
            currentPageIndex = @state.currentPageIndex

          @setState
            nodeArray: nodeArray
            nodeAnimation: {}

            currentNodeIndex: currentNodeIndex
            currentPageIndex: currentPageIndex
        else
          @setState
            nodeArray: nodeArray
            nodeAnimation: {}

        @callAction('reset') if _.isEmpty(@state.nodeArray)

      setTimeout(timeOutFunc, 350)

      # really remove the bookmark in DB
      Message.postMessage
        request: 'removeBookmark'
        id: @getCurrentNode().id
