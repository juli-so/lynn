# Matching shortcut keycode to action names
# c_x: C-x
# c_X: C-S-x
# s_x: S-x

KeyMatch =
  ctrlB: (event) ->
    event.ctrlKey and event.keyCode is 66
  
  pageUp: (event) ->
    event.keyCode is 33
  pageDown: (event) ->
    event.keyCode is 34

  getCommand: (event) ->
    ctrl = ''
    shift = ''
    if event.ctrlKey
      ctrl = 'c-'
    if event.shiftKey
      shift = 's-'

    ctrl + shift + event.keyCode

  match: (event, mode) ->
    switch mode
      when 'query' then @matchInQueryMode(event)
      when 'select' then @matchInSelectMode(event)
      when 'command' then @matchInCommandMode(event)
      else 'noop'

  matchInQueryMode: (event) ->
    switch @getCommand(event)
      when '13' then 'open'

      when 'c-8' then 'reset'

      when '33' then 'pageUp'
      when '34' then 'pageDown'
      when '38' then 'up'
      when '40' then 'down'

      when '9' then 'nextCommandMode'
      when 's-9' then 'prevCommandMode'

      else 'noop'

  matchInSelectMode: (event) ->
    switch @getCommand(event)
      when '33' then 'pageUp'
      when '34' then 'pageDown'
      when '38' then 'up'
      when '40' then 'down'

      when '9' then 'nextCommandMode'
      when 's-9' then 'prevCommandMode'

      when '13' then 's_open'
      # 'o'
      when '79' then 's_open'
      when '37' then 's_select'
      when '39' then 's_unselect'
      else 'noop'

  matchInCommandMode: (event) ->
    switch @getCommand(event)
      when '33' then 'pageUp'
      when '34' then 'pageDown'
      when '38' then 'up'
      when '40' then 'down'

      when '9' then 'nextCommandMode'
      when 's-9' then 'prevCommandMode'

      when '13' then 'c_execute'

      else 'noop'

