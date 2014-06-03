# c_x: C-x
# c_X: C-S-x
# s_x: S-x

KeyMatch =
  c_b: (event) ->
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

  switchInQueryMode: (event) ->
    switch @getCommand(event)
      # enter
      when '13' then 'open'

      # backspace
      when 'c-8' then 'reset'

      when '33' then 'pageUp'
      when '34' then 'pageDown'
      when '38' then 'up'
      when '40' then 'down'

      # tab
      when '9' then 'nextCommandMode'
      when 's-9' then 'prevCommandMode'

      else 'noop'

  switchInSelectMode: (event) ->
    switch @getCommand(event)
      when '33' then 'pageUp'
      when '34' then 'pageDown'
      when '38' then 'up'
      when '40' then 'down'

      when '9' then 'nextCommandMode'
      when 's-9' then 'prevCommandMode'

      when '13' then 's_open'
      when '37' then 's_select'
      else 'noop'

  switchInCommandMode: (event) ->
    switch @getCommand(event)
      when '33' then 'pageUp'
      when '34' then 'pageDown'
      when '38' then 'up'
      when '40' then 'down'

      when '9' then 'nextCommandMode'
      when 's-9' then 'prevCommandMode'

      else 'noop'

