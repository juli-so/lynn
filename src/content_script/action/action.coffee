Action =
  # match actionName to real action function
  matchAction: (actionName) ->
    switch actionName[0..1]
      when 'q_' then QueryAction[actionName[2..]]
      when 'f_' then FastAction[actionName[2..]]
      when 'c_' then CommandAction[actionName[2..]]
      when 's_' then SpecialAction[actionName[2..]]
      else CommonAction[actionName]
