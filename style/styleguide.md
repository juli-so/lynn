# Style Guide

* Naming
* Abbreviation
* Comment

## Naming

### Files
Coffee: **Lower camel case**, same as the name of its main object.  
`lynn.coffee`

### Chrome-related
Prefix with `c_`

### Arrays
Suffix with `Arr`.  
`nodeArr`

### Objects
**Upper camel case** for large, class-like objects.
`Lynn | ActionMatch`

For others, **lower camel case**.
`currTab`

### Functions
Lower camel case.  
Prefixs differ according to function types.  

- Helper: Prefix with `_`.  
  `_helper`

- Getter: Prefix with `g_`.  
  `g_currTab`

- Normal: No prefix.



## Abbreviation
**Only list uncommon abbreviations.**

NC: Non-Chrome

## Comment

### General
**Avoid periods.**  
**Start with uppercase.**

### File beginning
#### Formatting
0, 80: #  
1, 79: Space  
2-78: -

One empty line before and after.
One space between text and border.

#### Content
General description of utility.
Notes, if available, follow in a new block.

```coffee
# ---------------------------------------------------------------------------- #
#                                                                              #
# Store window and tab info here for easier retrieval                          #
#                                                                              #
# - All WinTab methods are bound to itself for easier chaining                 #
#                                                                              #
# ---------------------------------------------------------------------------- #
#                                                                              #
# Note: Do not use chrome.windows.getCurrent to get current window.            #
# From https://developer.chrome.com/extensions/windows                         #
#                                                                              #
#   The current window is the window that contains the code that is currently  #
#   executing. It's important to realize that this can be different from the   #
#   topmost or focused window.                                                 #
#                                                                              #
# ---------------------------------------------------------------------------- #

```

### Code
#### Formatting
Comment before code.  
Indentation same as next line of code.  
Starts with #, then a space, then - until col 64.

One empty line before and after.  
One space between # and comment.

```coffee
  # ------------------------------------------------------------
  # Init & Listen
  # ------------------------------------------------------------

  init: ->
    @_c_g_AllWin (winArr) =>
      @_update()
      @listen()

  listen: ->
    c_win = chrome.windows
    c_tab = chrome.tabs

    # ----------------------------------------------------------
    # Window events
    # ----------------------------------------------------------

    c_win.onCreated.addListener (win) =>
      @_c_g_AllWin(@_update)

    # ----------------------------------------------------------
    # Tab events
    # ----------------------------------------------------------

    c_tab.onCreated.addListener (tab) =>
      @_c_g_AllWin(@_update)
```

