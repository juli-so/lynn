# ---------------------------------------------------------------------------- #
#                                                                              #
# Blocks used for building Lynn                                                #
#                                                                              #
# ---------------------------------------------------------------------------- #

Top = React.createClass
  render: ->
    { input } = React.DOM

    if @props.specialMode isnt 'no'
      inputPlaceHolder =
        Hint.inputPlaceHolderSpecialModeMap[@props.specialMode]
    else
      inputPlaceHolder = switch @props.mode
        when 'query' then 'Search for...'
        when 'fast' then 'Invoke fast command!'
        when 'command' then 'Your command...'

    div { id: 'lynn_top' },
      input
        id: 'lynn_console_hint'
        type: 'text'
        size: '80'

        readOnly: true

        value: @props.hint

      input
        ref: 'lynn_console'
      
        id: 'lynn_console'
        type: 'text'
        size: '80'

        placeholder: inputPlaceHolder
        spellCheck: no

        value: @props.input
        onChange: @props.onConsoleChange

      span
        id: 'lynn_console_status_icon'
        className: 'fa fa-2x fa-fw ' + switch @props.mode
          when 'query'   then 'fa-search'
          when 'fast'    then 'fa-bolt'
          when 'command' then 'fa-terminal'

  componentDidUpdate: (prevProps, prevState) ->
    # focus input when toggled from invisible to visible
    if not prevProps.visible and @props.visible
      @refs.lynn_console.getDOMNode().focus()

Mid = React.createClass
  render: ->
    div { id: 'lynn_mid' },
      _.map @props.nodeArr[@props.start...@props.end], (node, index) =>
        animation = @props.nodeAnimation[@props.start + index] || 'lynn-fadeInLeft'

        Suggestion
          # Use dateAdded for nodes created from tabs
          key: node.url + (if node.id then node.id else node.dateAdded)

          node: node
          isCurrent: index is @props.currentNodeIndex
          isSelected: _.contains(@props.selectedArr, @props.start + index)

          animation: animation

          useSuggestedTag: @props.useSuggestedTag

Bot = React.createClass
  render: ->
    numToString = (num) ->
      if num > 10
        num.toString()
      else
        ['Zero', 'One', 'Two', 'Three', 'Four', 'Five',
        'Six', 'Seven', 'Eight', 'Nine', 'Ten'][num]

    infoString = @props.nodeArr.length + ' result'
    infoString += 's' if @props.nodeArr.length > 1

      
    div { id: 'lynn_bot' },
      span className: 'lynn_bot_left',
        infoString
      span className: 'lynn_bot_mid',
        if @props.specialMode is 'no'
          ''
        else
          botString = Hint.botStringSpecialModeMap[@props.specialMode]
          if @props.specialMode is 'storeWinSession' or
            @props.specialMode is 'storeChromeSession' or
            @props.specialMode is 'removeSession'
              sessionName = @props.input.split(' ')[0]
              botString += sessionName

          'Speical Mode: ' + botString
      span className: 'lynn_bot_right',
        'Page ' + numToString(@props.currentPageIndex + 1)

