##############################################################################
#
# UI component for accessor
#
##############################################################################

# Will be made into option later
MAX_SUGGESTION_NUM = 8

Accessor_ui =
  m_accessor: {}
  m_command_input: {}
  m_suggestion_box: {}

  m_suggestion_array: []
  m_node_array: []

  cap: 0
  currentIndex: 0

  init: ->
    @m_accessor = $("<div id='m_accessor'>")
    @m_command_input = $("<input id='m_command_input' type='text' size='80'>")
    @m_suggestion_box = $("<div id='m_suggestion_box'>")

    @m_accessor.append(@m_command_input).append(@m_suggestion_box)

    for i in [0...MAX_SUGGESTION_NUM]
      suggestion = @makeSuggestion()
      @m_suggestion_array[i] = suggestion
      @m_suggestion_box.append(suggestion)
      suggestion.hide()

    # Highlight current indexed suggestion
    @m_suggestion_array[@currentIndex].addClass('m_suggestion_current')

  clear: ->
    @m_command_input.val('')

    @m_suggestion_box.hide()

    @m_command_input.focus()

  getCurrentNode: ->
    @m_node_array[@currentIndex]

  prevSuggestion: ->
    @m_suggestion_array[@currentIndex].removeClass('m_suggestion_current')

    @currentIndex = (@currentIndex - 1 + @cap) % @cap
    @m_suggestion_array[@currentIndex].addClass('m_suggestion_current')
  
  nextSuggestion: ->
    @m_suggestion_array[@currentIndex].removeClass('m_suggestion_current')

    @currentIndex = (@currentIndex + 1) % @cap
    @m_suggestion_array[@currentIndex].addClass('m_suggestion_current')

  makeSuggestion: ->
    result = $("<div class='m_suggestion'>")
    mainline = $("<div class='m_mainline'>")
    tagline = $("<div class='m_tagline'>")

    #mainline.append("<span class='m_id'>>")
    mainline.append("<span class='m_title'>")

    result
      .append(mainline)
      .append(tagline)

    result

  setSuggestion: (index, node) ->
    @m_suggestion_array[index].find('.m_title').text(node.title)
    tagline = @m_suggestion_array[index].find('.m_tagline')
    tagline.children().remove()
    _.forEach(node.tagArray, (tag) ->
      if tag[0] == '@'
        tagline.append("<span class='m_tag'>#{tag}</span>")
      else
        tagline.append("<span class='m_tag'>##{tag}</span>")
    )

  renderSuggestion: (nodeArray) ->
    if _.isEmpty(nodeArray)
      @m_suggestion_box.hide()
    else
      @cap = Math.min(MAX_SUGGESTION_NUM, nodeArray.length)
      @m_node_array = nodeArray[0...@cap]
      
      @m_suggestion_box.show()

      # Render available results
      for node, i in @m_node_array
        @m_suggestion_array[i].show()
        #@m_suggestion_array[i].find('.m_id').text(node.id)
        @setSuggestion(i, node)

      # Hide empty suggestion boxes
      for i in [@cap...MAX_SUGGESTION_NUM]
        @m_suggestion_array[i].hide()
