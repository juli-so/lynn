##############################################################################
#
# Provide completion of tag, folder, etc
#
##############################################################################

Completion =

  # Return an array of tag
  suggestTag: (fragment) ->
    allTagName = Object.keys(Bookmark.tagNodeArray)

    result = _.filter(allTagName, (tag) ->
      _.contains(tag, fragment)
    )
    if _.isEmpty(result) then [fragment] else result

  # Preprocess query before sending it to Bookmark.find
  # Currently only complete each unfinished tag
  preprocess: (query) ->
    return '#' if query is '#'

    tokenArray = query.split(' ')
    newQueryArray = []

    _.forEach tokenArray, (token) =>
      if Bookmark.isTag(token)
        newQueryArray.push(@suggestTag(token)[0])
      else
        newQueryArray.push(token)

    newQueryArray.join(' ')

