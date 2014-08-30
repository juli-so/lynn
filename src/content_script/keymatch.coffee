# Keycode
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
# c_x: C-x
# c_X: C-S-x
# s_x: S-x

KeyMatch =
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

  match: (event, mode, specialMode) ->
    keyString = @getKeyString(event)
    # for debugging
    if keyString is 'c-p'
      return 'print'

    if specialMode isnt 'no'
      action = @matchInSpecialMode(keyString)
    else
      action = switch mode
        when 'query'   then @matchInQueryMode(keyString)
        when 'fast'    then @matchInFastMode(keyString)
        when 'command' then @matchInCommandMode(keyString)
        else 'noop'

    if action is 'noop' then @matchCommon(keyString) else action

  # ------------------------------------------------------------

  matchCommon: (keyString) ->
    switch keyString
      when 'esc'         then 'hide'
      when 'c-backspace' then 'reset'

      when 'upArrow'     then 'up'
      when 'c-k'         then 'up'
      when 'downArrow'   then 'down'
      when 'c-j'         then 'down'

      when 'c-h'         then 'f_select'
      when 'leftArrow'   then 'f_select'
      when 'c-l'         then 'f_unselect'
      when 'rightArrow'  then 'f_unselect'

      when 'pageUp'      then 'pageUp'
      when 'c-u'         then 'pageUp'
      when 'pageDown'    then 'pageDown'
      when 'c-d'         then 'pageDown'

      when 'tab'         then 'nextMode'
      when 's-tab'       then 'prevMode'

      when 'c-r'         then 'f_remove'

      when 'c-q'         then 'test'

      else 'noop'

  # ------------------------------------------------------------

  matchInQueryMode: (keyString) ->
    switch keyString
      when 'enter'       then 'open'
      when 'c-enter'     then 'openInBackground'
      when 's-enter'     then 'openInNewWindow'
      when 'c-s-enter'   then 'openInNewIncognitoWindow'

      else 'noop'

  matchInFastMode: (keyString) ->
    switch keyString
      when 'enter'       then 'open'
      when 'o'           then 'open'
      when 'c-enter'     then 'openInBackground'
      when 'c-o'         then 'openInBackground'
      when 's-enter'     then 'openInNewWindow'
      when 's-o'         then 'openInNewWindow'
      when 'c-s-enter'   then 'openInNewIncognitoWindow'
      when 'c-s-o'       then 'openInNewIncognitoWindow'

      when 'k'           then 'up'
      when 'j'           then 'down'

      when 'leftArrow'   then 'f_select'
      when 'h'           then 'f_select'
      when 'rightArrow'  then 'f_unselect'
      when 'l'           then 'f_unselect'

      when 'a'           then 'f_toggleAllSelectionInCurrentPage'
      when 's-a'         then 'f_toggleAll'

      when 'u'           then 'pageUp'
      when 'd'           then 'pageDown'

      when 't'           then 'f_tag'

      when 'r'           then 'f_remove'

      else 'noop'

  matchInCommandMode: (keyString) ->
    switch keyString
      when 'enter'  then 'c_execute'

      else 'noop'
  # ------------------------------------------------------------

  matchInSpecialMode: (keyString) ->
    switch keyString
      when 'enter' then 's_confirm'
      when 'esc' then 's_abort'

      else 'noop'
