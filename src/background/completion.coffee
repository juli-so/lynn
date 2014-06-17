##############################################################################
#
# Provide completion of tag, folder, etc
#
##############################################################################

Completion =
  allTagName: []

  init: ->
    @allTagName = Object.keys(Bookmark.tagNodeArray)

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

    _.forEach tokenArray, (token) =>
      if token[0] is '#' or token[0] is '@'
        newQueryArray.push(@suggestTag(token)[0])
      else
        newQueryArray.push(token)

    newQueryArray.join(' ')

