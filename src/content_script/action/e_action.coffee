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

E_Action =
  esc: ->
    @callAction('n_hide')

  enter: ->
    if @state.mode is 'query' or @state.mode is 'fast'
      @callAction('n_open')
    else
      # Special mode 
      if @state.specialMode isnt 'no'
        @callAction('s_' + @state.specialMode)
        @callAction('n_hide')
        
      # Command mode
      else
        if not Util.startsWith(@state.input, ':')
          return

        tokenArray = @state.input.split(' ')
        command = tokenArray[0][1..]
        args    = tokenArray[1..]

        if CommandMap[command]
          @callAction(CommandMap[command], args)

        @callAction('hide')
        # groupMap here

  s_enter: ->
    if @state.mode is 'query' or @state.mode is 'fast'
      @callAction('n_openInBackground')

  c_enter: ->
    if @state.mode is 'query' or @state.mode is 'fast'
      @callAction('n_openInNewWindow')

  c_s_enter: ->
    if @state.mode is 'query' or @state.mode is 'fast'
      @callAction('n_openInNewIncognitoWindow')

