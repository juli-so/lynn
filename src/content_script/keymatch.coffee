# Matching shortcut keycode to action names
# c_x: C-x
# c_X: C-S-x
# s_x: S-x

KeyMatch =
  ctrlB: (event) ->
    event.ctrlKey and event.keyCode is 66
  
  getCommand: (event) ->
    ctrl = ''
    shift = ''
    if event.ctrlKey
      ctrl = 'c-'
    if event.shiftKey
      shift = 's-'

    ctrl + shift + event.keyCode

  match: (event, mode) ->
    keyCode = @getCommand(event)
    # for debugging
    if keyCode is 'c-76'
      return 'print'

    #return @matchCommon(keyCode) if @matchCommon(keyCode) isnt 'noop'

    action = switch mode
      when 'query' then @matchInQueryMode(keyCode)
      when 'fast' then @matchInFastMode(keyCode)
      when 'command' then @matchInCommandMode(keyCode)
      else 'noop'

    if action is 'noop' then @matchCommon(keyCode) else action

  matchCommon: (keyCode) ->
    switch keyCode
      when '27' then 'hide'
      when 'c-8' then 'reset'

      when '38'   then 'up'
      when 'c-75' then 'up'
      when '40'   then 'down'
      when 'c-74' then 'down'

      when '33'   then 'pageUp'
      when 'c-85' then 'pageUp'
      when '34'   then 'pageDown'
      when 'c-68' then 'pageDown'

      when '9'   then 'nextMode'
      when 's-9' then 'prevMode'

      else 'noop'

  matchInQueryMode: (keyCode) ->
    switch keyCode
      when '13' then 'open'

      else 'noop'

  matchInFastMode: (keyCode) ->
    switch keyCode
      when '13' then 'f_open'
      when '79' then 'f_open'

      when '37' then 'f_select'
      when '39' then 'f_unselect'

      else 'noop'

  matchInCommandMode: (keyCode) ->
    switch keyCode
      when '13' then 'c_execute'

      else 'noop'
