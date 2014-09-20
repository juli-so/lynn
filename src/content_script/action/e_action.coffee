# Handle Esc and Enter actions
# Most actions are delegated to N_Action, I_Action, and S_Action

# Actions to be made in command mode
CommandMap =
  'a'             : 'i_addBookmark'
  'am'            : 'i_addMultipleBookmark'
  'aa'            : 'i_addAllCurrentWindowBookmark'
  'aA'            : 'i_addAllWindowBookmark'

  's'             : 'i_storeWindowSession'
  'S'             : 'i_storeChromeSession'
  'rs'            : 'i_removeSession'

  'l'             : 'n_lastWindow'
  's-l'           : 'n_lastWindowInBackground'
  'c-l'           : 'n_lastWindowInNewWindow'
  'c-s-l'         : 'n_lastWindowInNewIncognitoWindow'

  'r'             : 'i_recoverBookmark'

  'al'            : 'i_addLinkBookmark'

E_Action =
  esc: ->
    if @state.specialMode isnt 'no'
      @callAction('e_escFromSpecialMode')
    else
      if @isResetted()
        @callAction('n_hide')
      else
        @callAction('n_reset')

  escFromSpecialMode: ->
    @setState { specialMode: 'no' }
    @callAction('n_recoverFromCache')
    @callAction('n_clearCache')

  # ------------------------------------------------------------

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
        else if @state.sessionMap[command]
          @callAction('n_openSession', [command, modifierString])

  s_enter: ->
    @callAction('e_enter', ['s-'  ])

  c_enter: ->
    @callAction('e_enter', ['c-'  ])

  c_s_enter: ->
    @callAction('e_enter', ['c-s-'])

