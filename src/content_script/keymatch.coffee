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
    # for debugging
    if @getCommand(event) is 'c-68'
      return 'print'

    return @matchCommon(event) if @matchCommon(event) isnt 'noop'

    switch mode
      when 'query' then @matchInQueryMode(event)
      when 'select' then @matchInSelectMode(event)
      when 'command' then @matchInCommandMode(event)
      else 'noop'

  matchCommon: (event) ->
    switch @getCommand(event)
      when '27' then 'hide'
      when 'c-8' then 'reset'

      when '38' then 'up'
      when '40' then 'down'

      when '33' then 'pageUp'
      when '34' then 'pageDown'

      when '9' then 'nextMode'
      when 's-9' then 'prevMode'

      else 'noop'


  matchInQueryMode: (event) ->
    switch @getCommand(event)
      when '13' then 'open'

      else 'noop'

  matchInSelectMode: (event) ->
    switch @getCommand(event)
      when '13' then 's_open'
      when '79' then 's_open'
      when '37' then 's_select'
      when '39' then 's_unselect'

      else 'noop'

  matchInCommandMode: (event) ->
    switch @getCommand(event)
      when '13' then 'c_execute'

      else 'noop'

