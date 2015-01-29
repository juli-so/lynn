# ---------------------------------------------------------------------------- #
#                                                                              #
# Tag management                                                               #
#                                                                              #
# * Auto-tagging                                                               #
#                                                                              #
# ---------------------------------------------------------------------------- #

# --------------------------------------------------------------
# Auto-tagging
# --------------------------------------------------------------
#
# autoTaggingMap = {
#   #tag: {
#     matchProp: 'title'
#     matchType: 'contains'
#     matchStr : 'amazon'
#   }
# }
#
# matchProp is 'title' | 'hostname'
# matchType is 'contains'           for 'title' (case-insensitive)
#              'contains' | 'exact' for 'hostname'
#
# --------------------------------------------------------------

Tag =
  # For auto-tagging
  titleContainsMap: {}
  hostnameExactMap: {}
  hostnameContainsMap: {}

  init: ->
    autoTaggingMap = CStorage.getState('autoTaggingMap')

    _.forEach autoTaggingMap, (taggingRule, tag) =>
      { matchProp, matchType, matchStr } = taggingRule
      if matchProp is 'title'
        @titleContainsMap[matchStr] = tag
      else # match against hostname
        if matchType is 'exact'
          @hostnameExactMap[matchStr] = tag
          @hostnameExactMap['www.' + matchStr] = tag
        else
          @hostnameContainsMap[matchStr] = tag

  autoTag: (title, hostname) ->
    tagArr = []

    _.forEach @titleContainsMap, (tag, matchStr) =>
      if _.ciContains(title, matchStr)
        tagArr.push(tag)

    _.forEach @hostnameExactMap, (tag, matchStr) =>
      if matchStr is hostname
        tagArr.push(tag)

    _.forEach @hostnameContainsMap, (tag, matchStr) =>
      if _.ciContains(hostname, matchStr)
        tagArr.push(tag)

    tagArr
      
  _log: ->
    console.log @titleContainsMap
    console.log @hostnameExactMap
    console.log @hostnameContainsMap

