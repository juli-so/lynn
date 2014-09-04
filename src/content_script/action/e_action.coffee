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

        @callAction(CommandMap[modifierString + command], args)

        @callAction('hide')
        # groupMap here

  s_enter: ->
    @callAction('e_enter', ['s-'  ])

  c_enter: ->
    @callAction('e_enter', ['c-'  ])

  c_s_enter: ->
    @callAction('e_enter', ['c-s-'])

