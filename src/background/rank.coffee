# ---------------------------------------------------------------------------- #
#                                                                              #
# Rank search results by computing relevance                                   #
#                                                                              #
# ---------------------------------------------------------------------------- #

MATCH_POINT     = 10
HALFMATCH_POINT = 5
MISMATCH_POINT  = -2

S_KW_MATCH_POINT           = 10
S_KW_MISMATCH_POINT        = -2

S_INTERSECTION_MATCH_POINT = 10
S_DIFF_MATCH_POINT         = 5
S_DIFF_MISMATCH_POINT      = -1

Rank =
  # ------------------------------------------------------------
  # Normal rank
  # ------------------------------------------------------------

  rank: (kwArr, tagArr, nodeArr) ->
    sortFunc = (node) =>
      -@getRelavance(kwArr, tagArr, node)
    _.sortBy(nodeArr, sortFunc)

  # ------------------------------------------------------------
  # For each keyword
  #   Match:     + 10
  #   Mismatch:  - 2
  # For each tag
  #   Match:     + 10
  #   Halfmatch: + 5 # e.g: input has #ru then #ruby is a halfmatch
  #   Mismatch:  - 2
  # ------------------------------------------------------------
  getRelavance: (kwArr, tagArr, node) ->
    kwPoint = 0
    _.forEach kwArr, (kw) ->
      if _.ciContains(node.title, kw)
        kwPoint += MATCH_POINT
      else
        kwPoint += MISMATCH_POINT

    tagPoint = 0
    _.forEach node.tagArr, (tag) ->
      if _.any(tagArr, _.ciEquals(tag))
        tagPoint += MATCH_POINT
      else if _.any(tagArr, _.ciContains(tag))
        tagPoint += HALFMATCH_POINT
      else
        tagPoint += MISMATCH_POINT

    kwPoint + tagPoint

  # ------------------------------------------------------------
  # Strict rank
  # ------------------------------------------------------------
  rankStrict: (kwArr, intersection, diff, nodeArr) ->
    sortFunc = (node) =>
      -@getStrictRelavance(kwArr, intersection, diff, node)
    _.sortBy(nodeArr, sortFunc)

  # ------------------------------------------------------------
  #   For each keyword:
  #     Match:     + 10
  #     Mismatch:  - 2
  #   For each tag in intersection
  #     Match:     + 10
  #   For each tag in diff
  #     Match:     + 5
  #     Mismatch   - 1
  # ------------------------------------------------------------
  getStrictRelavance: (kwArr, intersection, diff, node) ->
    kwPoint = 0
    _.forEach kwArr, (kw) ->
      if _.ciContains(node.title, kw)
        kwPoint += S_KW_MATCH_POINT
      else
        kwPoint += S_KW_MISMATCH_POINT

    tagPoint = 0
    _.forEach node.tagArr, (tag) ->
      if _.any(intersection, _.ciEquals(tag))
        tagPoint += S_INTERSECTION_MATCH_POINT
      else if _.any(diff, _.ciEquals(tag))
        tagPoint += S_DIFF_MATCH_POINT
      else
        tagPoint += S_DIFF_MISMATCH_POINT

    kwPoint + tagPoint

