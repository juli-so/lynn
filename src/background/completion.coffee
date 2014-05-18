##############################################################################
#
# Provide completion of tag, folder, etc
#
##############################################################################

Completion =
  allTagName: []

  init: ->
    @allTagName = Object.keys(Bookmark.linkedID)

  # Return an array of tag
  suggestTag: (fragment) ->
    result = _.filter(@allTagName, (tag) ->
      _.contains(tag, fragment)
    )
    if _.isEmpty(result) then [fragment] else result

  # Preprocess query before sending it to Bookmark.find
  # Currently only complete each unfinished tag
  preprocess: (query) ->

    tokenArray = query.split(' ')
    newQueryArray = []

    _.forEach(tokenArray, ((token) ->
      if token[0] == '#'
        newQueryArray.push('#' + @suggestTag(token.slice(1))[0])
      else if token[0] == '@'
        newQueryArray.push(@suggestTag(token)[0])
      else
        newQueryArray.push(token)
    ).bind(@))

    newQueryArray.join(' ')

