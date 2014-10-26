# ---------------------------------------------------------------------------- #
#                                                                              #
# Rank search results by computing relevance                                   #
#                                                                              #
# ---------------------------------------------------------------------------- #
#                                                                              #
# Relevance computation algorithm:                                             #
#  For each keyword                                                            #
#    Match:    + 10                                                            #
#    Mismatch: - 2                                                             #
#  For each tag                                                                #
#    Match:     + 10                                                           #
#    Halfmatch: + 5 # e.g: input has #ru then #ruby is a halfmatch             #
#    Mismatch:  - 2                                                            #
#                                                                              #
#                                                                              #
#  Each keyword/tag is considered a token                                      #
#  Match:    + 10                                                              #
#  Mismatch: - 2                                                               #
#                                                                              #
# ---------------------------------------------------------------------------- #

MATCH_POINT     = 10
HALFMATCH_POINT = 5
MISMATCH_POINT  = -2

Rank =
  rank: (keywordArr, tagArr, nodeArr) ->
    sortFunc = (node) =>
      -@getRelavance(keywordArr, tagArr, node)
    _.sortBy(nodeArr, sortFunc)

  getRelavance: (keywordArr, tagArr, node) ->
    keywordPoint = 0
    _.forEach keywordArr, (kw) ->
      if _.ciContains(node.title, kw)
        keywordPoint += MATCH_POINT
      else
        keywordPoint += MISMATCH_POINT

    tagPoint = 0
    _.forEach node.tagArr, (tag) ->
      if _.any(tagArr, _.ciEquals(tag))
        tagPoint += MATCH_POINT
      else if _.any(tagArr, _.ciContains(tag))
        tagPoint += HALFMATCH_POINT
      else
        tagPoint += MISMATCH_POINT

    keywordPoint + tagPoint

