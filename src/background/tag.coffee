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
    chrome.storage.sync.get 'autoTaggingMap', (storageObj) =>
      autoTaggingMap = storageObj.autoTaggingMap
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

  autoTag: (title, hostname) ->
    tagArr = []

    _.forEach @titleContainsMap, (tag, matchString) =>
      if Util.ciContains(title, matchString)
        tagArr.push(tag)

    _.forEach @hostnameExactMap, (tag, matchString) =>
      if matchString is hostname
        tagArr.push(tag)

    _.forEach @hostnameContainsMap, (tag, matchString) =>
      if Util.ciContains(hostname, matchString)
        tagArr.push(tag)

    tagArr
      
  _log: ->
    console.log @titleContainsMap
    console.log @hostnameExactMap
    console.log @hostnameContainsMap

