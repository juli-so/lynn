# ---------------------------------------------------------------------------- #
#                                                                              #
# Match keys to actions                                                        #
#                                                                              #
# ---------------------------------------------------------------------------- #
#                                                                              #
# Note: Some chrome shortcuts, namely                                          #
#   c/c-s + t/n/w                                                              #
#   will not be sent to keydown handler                                        #
# See http://src.chromium.org/viewvc/chrome?revision=127787&view=revision      #
#                                                                              #
# ---------------------------------------------------------------------------- #

DEBUG = yes

Key =
  '8'  : 'backspace'
  '9'  : 'tab'
  '13' : 'enter'
  '27' : 'esc'

  '33' : 'pageUp'
  '34' : 'pageDown'
  '35' : 'end'
  '36' : 'home'

  '46' : 'delete'

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

    # Exit
    return 'n_hide'       if keyString is 'c-q'

    # Reset
    return 'n_reset'       if keyString is 'c-c'

    # E_Action
    return 'e_esc'        if keyString is 'esc'
    return 'e_enter'      if keyString is 'enter'
    return 'e_c_enter'    if keyString is 'c-enter'
    return 'e_s_enter'    if keyString is 's-enter'
    return 'e_c_s_enter'  if keyString is 'c-s-enter'

    if specialMode isnt 'no'
      if @matchInSpecialMode(keyString, specialMode) isnt 'noop'
        action = @matchInSpecialMode(keyString, specialMode)
      else
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

    console.log action if DEBUG

    return action

  # Find the real action function
  findAction: (actionName) ->
    switch actionName[0..1]
      when 'n_' then N_Action[actionName[2..]]
      when 'i_' then I_Action[actionName[2..]]
      when 'e_' then E_Action[actionName[2..]]
      when 's_' then S_Action[actionName[2..]]
      when 't_' then T_Action[actionName[2..]]
      else _.noop

  # ------------------------------------------------------------

  # Actions shared in all modes
  # Can be overridden by actions defined specifically for other modes
  matchCommon: (keyString) ->
    actionMap =
      'tab':              'n_nextMode'
      's-tab':            'n_prevMode'

      'c-backspace':      'n_clearInput'

      # Movement
      'upArrow':          'n_up'
      'c-k':              'n_up'
      'downArrow':        'n_down'
      'c-j':              'n_down'

      'pageUp':           'n_pageUp'
      'c-u':              'n_pageUp'
      'pageDown':         'n_pageDown'
      'c-d':              'n_pageDown'

      # Selection
      'c-h':              'n_select'
      'leftArrow':        'n_select'
      'c-l':              'n_unselect'
      'rightArrow':       'n_unselect'

      'c-a':              'n_toggleAllSelectionInCurrentPage'
      'c-s-a':            'n_toggleAll'

      # Other N_Action

    actionMap[keyString] || 'noop'

  # ------------------------------------------------------------

  matchInQueryMode: (keyString) ->
    actionMap =
      'c-backspace':      'n_deletePrevWord'
      'c-delete':         'n_deleteNextWord'

      'c-leftArrow':      'n_setCaretToPrevWord'
      'c-rightArrow':     'n_setCaretToNextWord'

      'c-r':              'n_remove'

    actionMap[keyString] || 'noop'


  matchInFastMode: (keyString) ->
    actionMap =
      # Directly switching to Command Mode
      # Shift since semicolon requires Shift
      's-semicolon':      'n_nextMode'

      # Opening bookmarks
      'o':                'n_open'
      's-o':              'n_openInBackground'
      'c-o':              'n_openInNewWin'
      'c-s-o':            'n_openInNewIncognitoWin'

      # Movment
      'k':                'n_up'
      'j':                'n_down'

      'u':                'n_pageUp'
      'd':                'n_pageDown'

      # Selection
      'h':                'n_select'
      'leftArrow':        'n_select'
      'l':                'n_unselect'
      'rightArrow':       'n_unselect'

      'a':                'n_toggleAllSelectionInCurrentPage'
      's-a':              'n_toggleAll'

      # Insertion
      'c':                'n_clearInput'
      
      'i':                'n_insert'
      's-i':              'n_insertBefore'

      # Other N_Action
      'r':                'n_remove'
      'forwardSlash':     'n_goQueryMode'

      # I_Action
      't':                'i_tag'
      's-t':              'i_editTag'

    actionMap[keyString] || 'noop'

  # ------------------------------------------------------------

  matchInCommandMode: (keyString) ->
    actionMap =
      'c-a':              'n_setCaretToStart'
      'c-e':              'n_setCaretToEnd'

    actionMap[keyString] || 'noop'

  # ------------------------------------------------------------

  matchInSpecialMode: (keyString, specialMode) ->
    commonActionMap =
      'c-a':                'n_setCaretToStart'
      'c-e':                'n_setCaretToEnd'

      'c-backspace':        'n_deletePrevWord'
      'c-delete':           'n_deleteNextWord'

      'c-leftArrow':        'n_setCaretToPrevWord'
      'c-rightArrow':       'n_setCaretToNextWord'


    actionMap =
      'recoverBookmark':
        'k':                'n_up'
        'k':                'n_up'
        'j':                'n_down'

        'u':                'n_pageUp'
        'd':                'n_pageDown'
        'h':                'n_select'
        'l':                'n_unselect'

        'a':                'n_toggleAllSelectionInCurrentPage'
        's-a':              'n_toggleAll'

        'c-backspace':      'noop'

        'c-a':              'noop'
        'c-e':              'noop'

    if actionMap[specialMode] and actionMap[specialMode][keyString]
      actionMap[specialMode][keyString]
    else
      commonActionMap[keyString] || 'noop'
