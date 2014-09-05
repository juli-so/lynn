# Handle Esc and Enter actions
# Most actions are delegated to N_Action, I_Action, and S_Action

# Actions to be made in command mode
CommandMap =
  'a'             : 'i_addBookmark'
  'am'            : 'i_addMultipleBookmark'
  'aa'            : 'i_addAllCurrentWindowBookmark'
  'aA'            : 'i_addAllWindowBookmark'

  'g'             : 'i_addGroup'
  'ug'            : 'i_removeGroup'

  'l'             : 'n_lastWindow'
  's-l'           : 'n_lastWindowInBackground'
  'c-l'           : 'n_lastWindowInNewWindow'
  'c-s-l'         : 'n_lastWindowInNewIncognitoWindow'

E_Action =
  esc: ->
    @callAction('n_hide')

  enter: (modifierString = '') ->
    # Special mode
    if @state.specialMode isnt 'no'
      @callAction('s_' + @state.specialMode)
    else
      # Query | Fast mode
      if @state.mode is 'query' or @state.mode is 'fast'
        switch modifierString
          when ''       then @callAction('n_open')
          when 's-'     then @callAction('n_openInBackground')
          when 'c-'     then @callAction('n_openInNewWindow')
          when 'c-s-'   then @callAction('n_openInNewIncognitoWindow')
      # Command mode
      else
        if not Util.startsWith(@state.input, ':')
          return

        tokenArray = @state.input.split(' ')
        command = tokenArray[0][1..]
        args    = tokenArray[1..]

        if CommandMap[modifierString + command]
          @callAction(CommandMap[modifierString + command], args)
        else if @state.groupMap[command]
          nodeArray = @state.groupMap[command]

          openArgs = switch modifierString
            when ''       then [{ active: yes }, no , yes, nodeArray]
            when 's-'     then [{ active: no  }, no , no , nodeArray]
            when 'c-'     then [{ incognito: yes }, yes, yes, nodeArray]
            when 'c-s-'   then [{ incognito: yes }, yes, yes, nodeArray]
          @callAction('n_openHelper', openArgs)

  open: ->
    @callAction('n_openHelper', [{ active:    yes }, no , yes])

  openInBackground: ->
    @callAction('n_openHelper', [{ active:    no  }, no , no ])

  openInNewWindow: ->
    @callAction('n_openHelper', [{ incognito: no  }, yes, yes])

  openInNewIncognitoWindow: ->
    @callAction('n_openHelper', [{ incognito: yes }, yes, yes])



  s_enter: ->
    @callAction('e_enter', ['s-'  ])

  c_enter: ->
    @callAction('e_enter', ['c-'  ])

  c_s_enter: ->
    @callAction('e_enter', ['c-s-'])

