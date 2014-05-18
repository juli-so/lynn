########################################################################
#
# Providing basic functionality
#
########################################################################

Util =
  # ci = Case insensitive
  ciContains: (str, fragment) ->
    str.toLowerCase().indexOf(fragment.toLowerCase()) != -1
