# Match keys to actions

# Note: Some chrome shortcuts, namely 
#   c/c-s + t/n/w
#   will not be sent to keydown handlers
# See http://src.chromium.org/viewvc/chrome?revision=127787&view=revision

Key =
  '8'  : 'backspace'
  '9'  : 'tab'
  '13' : 'enter'
  '27' : 'esc'

  '33' : 'pageUp'
  '34' : 'pageDown'
  '35' : 'end'
  '36' : 'home'

  '38' : 'upArrow'
  '40' : 'downArrow'
  '37' : 'leftArrow'
  '39' : 'rightArrow'

  '188': 'comma'
  '190': 'period'
  '186': 'semicolon'
  '191': 'forwardSlash'
  '220': 'backSlash'
  '192': 'grave'
  '219': 'openBracket'
  '221': 'closeBracket'

  '48' : '0'
  '49' : '1'
  '50' : '2'
  '51' : '3'
  '52' : '4'
  '53' : '5'
  '54' : '6'
  '55' : '7'
  '56' : '8'
  '57' : '9'

  '65' : 'a'
  '66' : 'b'
  '67' : 'c'
  '68' : 'd'
  '69' : 'e'
  '70' : 'f'
  '71' : 'g'
  '72' : 'h'
  '73' : 'i'
  '74' : 'j'
  '75' : 'k'
  '76' : 'l'
  '77' : 'm'
  '78' : 'n'
  '79' : 'o'
  '80' : 'p'
  '81' : 'q'
  '82' : 'r'
  '83' : 's'
  '84' : 't'
  '85' : 'u'
  '86' : 'v'
  '87' : 'w'
  '88' : 'x'
  '89' : 'y'
  '90' : 'z'

# Matching shortcut keycode to action names
ActionMatch =
  # App-invoking shortcut
  isInvoked: (event) ->
    @getKeyString(event) is 'c-b'
  
  getKeyString: (event) ->
    ctrl = ''
    shift = ''
    if event.ctrlKey
      ctrl = 'c-'
    if event.shiftKey
      shift = 's-'

    ctrl + shift + Key[event.keyCode.toString()]

  # ------------------------------------------------------------

  findActionName: (event, mode, specialMode) ->
    keyString = @getKeyString(event)

    # Log for debugging
    return 'n_log'        if keyString is 'c-p'

    # E_Action
    return 'e_esc'        if keyString is 'esc'
    return 'e_enter'      if keyString is 'enter'
    return 'e_c_enter'    if keyString is 'c-enter'
    return 'e_s_enter'    if keyString is 's-enter'
    return 'e_c_s_enter'  if keyString is 'c-s-enter'

    if specialMode isnt 'no'
      action = switch keyString
        when 'tab'   then 'noop'
        when 's-tab' then 'noop'
        else @matchCommon(keyString)
    else
      action = switch mode
        when 'query'   then @matchInQueryMode(keyString)
        when 'fast'    then @matchInFastMode(keyString)
        # Only for shortcuts
        # Actions made when using Enter are processed in E_Action
        when 'command' then @matchInCommandMode(keyString)
        else 'noop'

      action = @matchCommon(keyString) if action is 'noop'
      return action

  # Find the real action function
  findAction: (actionName) ->
    switch actionName[0..1]
      when 'n_' then N_Action[actionName[2..]]
      when 'i_' then I_Action[actionName[2..]]
      when 'e_' then E_Action[actionName[2..]]
      when 's_' then S_Action[actionName[2..]]
      else _.noop

  # ------------------------------------------------------------

  # Actions shared in all modes
  # Can be overridden by actions defined specifically for other modes
  matchCommon: (keyString) ->
    switch keyString
      when 'tab'          then 'n_nextMode'
      when 's-tab'        then 'n_prevMode'

      # Movement
      when 'upArrow'      then 'n_up'
      when 'c-k'          then 'n_up'
      when 'downArrow'    then 'n_down'
      when 'c-j'          then 'n_down'

      when 'pageUp'       then 'n_pageUp'
      when 'c-u'          then 'n_pageUp'
      when 'pageDown'     then 'n_pageDown'
      when 'c-d'          then 'n_pageDown'

      # Selection
      when 'c-h'          then 'n_select'
      when 'leftArrow'    then 'n_select'
      when 'c-l'          then 'n_unselect'
      when 'rightArrow'   then 'n_unselect'

      when 'c-a'          then 'n_toggleAllSelectionInCurrentPage'
      when 'c-s-a'        then 'n_toggleAll'

      # Other N_Action

      else 'noop'

  # ------------------------------------------------------------

  matchInQueryMode: (keyString) ->
    switch keyString
      # Temporarily disable this in case accidentally removed bookmarks
      #when 'c-r'          then 'n_remove'
      when 'c-backspace'  then 'n_clearInput'

      when 'c-r'          then 'n_remove'

      else 'noop'

  matchInFastMode: (keyString) ->
    switch keyString
      # Opening bookmarks
      when 'o'            then 'n_open'
      when 's-o'          then 'n_openInBackground'
      when 'c-o'          then 'n_openInNewWindow'
      when 'c-s-o'        then 'n_openInNewIncognitoWindow'

      # Movment
      when 'k'            then 'n_up'
      when 'j'            then 'n_down'

      when 'u'            then 'n_pageUp'
      when 'd'            then 'n_pageDown'

      # Selection
      when 'h'            then 'n_select'
      when 'l'            then 'n_unselect'

      when 'a'            then 'n_toggleAllSelectionInCurrentPage'
      when 's-a'          then 'n_toggleAll'

      # Other N_Action
      when 'r'            then 'n_remove'
      when 'forwardSlash' then 'n_goQueryMode'

      # I_Action
      when 't'            then 'i_tag'
      when 's-t'          then 'i_editTag'

      else 'noop'

  # ------------------------------------------------------------

  matchInCommandMode: (keyString) ->
    switch keyString
      when 'c-backspace'  then 'n_clearInput'

      else 'noop'
