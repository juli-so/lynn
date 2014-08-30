# manages
#   * auto-tagging

# autoTaggingMap is saved in syncStorage
# it has the following structure
# autoTaggingMap = {
#   '#tag1': { 
#     matchProp: 'title'
#     matchType: 'exact'
#     matchString: 'amazon.com'
#   }
#
#   '#tag2': ...
# }
# matchProp is 'title' | 'hostname'
# matchType is 'contains' for 'title' (case-insensitive)
#              'contains' | 'exact' for 'hostname'

Tag =
  init: ->
    chrome.storage.sync.get 'autoTaggingMap', (storageObject) =>
      autoTaggingMap = storageObject.autoTaggingMap
      @titleContainsMap = {}
      @hostnameExactMap = {}
      @hostnameContainsMap = {}

      _.forEach autoTaggingMap, (taggingRule, tag) =>
        { matchProp, matchType, matchString } = taggingRule
        if matchProp is 'title'
          @titleContainsMap[matchString] = tag
        else # match against hostname
          if matchType is 'exact'
            @hostnameExactMap[matchString] = tag
            @hostnameExactMap['www.' + matchString] = tag
          else
            @hostnameContainsMap[matchString] = tag

  _ciContains: (str, fragment) ->
    str.toLowerCase().indexOf(fragment.toLowerCase()) isnt -1

  _log: ->
    console.log @titleContainsMap
    console.log @hostnameExactMap
    console.log @hostnameContainsMap

  autoTag: (title, hostname) ->
    tagArray = []

    _.forEach @titleContainsMap, (tag, matchString) =>
      if @_ciContains(title, matchString)
        tagArray.push(tag)

    _.forEach @hostnameExactMap, (tag, matchString) =>
      if matchString is hostname
        tagArray.push(tag)

    _.forEach @hostnameContainsMap, (tag, matchString) =>
      if @_ciContains(hostname, matchString)
        tagArray.push(tag)

    tagArray
      
