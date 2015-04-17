## Documentation

### First things first

1. Use **Ctrl-B** to invoke/hide Lynn  
Try entering some random words to find bookmarks you want, and press **Enter** to open them!

2. All tags start with **#** or **@**  
Although **@** is primarily designed to use with websites, such as an item page in Amazon 
would be tagged with @amazon, you can use it however you like.

3. Lynn has three modes:  

<div class="mode">
  <table>
      <tr>
        <td><i class='fa fa-2x fa-fw fa-search'  ></i></td>
        <td><i class='fa fa-2x fa-fw fa-bolt'    ></i></td>
        <td><i class='fa fa-2x fa-fw fa-terminal'></i></td>
      </tr>
      <tr>
        <td>Query  </td>
        <td>Fast   </td>
        <td>Command</td>
      </tr>
  </table>
</div>

**Query**  
Search for bookmarks.  

**Fast**  
Issue fast commands to open bookmarks, manipulate tags, etc (Like Vim's Normal-mode).  
You can't change the query in this mode.

**Command**  
Enter commands to add bookmarks, intereact with webpages, etc.  
You can't change the query, or open bookmark in this mode.

Use **Tab** & **S-Tab** to switch forward/backward mode.  

**Notation**:

  S-x -> Shift-x | C-x -> Ctrl-x | C-S-x -> Ctrl-Shift-x

---

### Search
When you start Lynn, you are in Query mode where you can search for bookmarks.  
Typing some words in, and bookmarks containing **all** those words in their titles
will show up.  
Later when you have added tags, you can also search by tags.  

Up/down arrow or C-k/C-j to go up/down.  
Left/right arrow or C-h/C-l to select/unselect.  
Enter/S-Enter/C-Enter/C-S-Enter to open current bookmark, or all selected bookmarks
if any bookmark get selected:

- Current window. Hide Lynn and go to last opened one.
- Current window. Open in background, stay in current tab and keep Lynn open.
- New window.
- New private window.


### Shortcuts
Lynn is **heavily** shortcut-based, so you need to learn them to be effective.  
Most shortcust are similar to their counterparts in Vim.  
It is advised to experience Lynn while reading this part by opening another Chrome window.

---

#### All Modes
Here is a list of commands available in **All Modes**.  
Some commands which behave differently in different modes are not in this section.

---

**C-B**  
Show/Hide Lynn.

**C-Q**  
Hide Lynn.

**C-C**  
Reset to Query Mode and clear the console.  

**Resetted** means In Query Mode and console clear.

**Esc**  
If during using a command, abort it.  
Otherwise do **C-C**.  
If **Resetted**, Hide Lynn.

---

**Tab** & **S-Tab**  
Go to prev/next mode according to the sequence [Query -> Fast -> Command -> Query].

**Entering semicolon in Query Mode goes to Command Mode.**  
**Backspace in Command Mode when Command prompt is empty goes to Query Mode.**  

---

#### Query & Fast Mode
Nearly all commands available in Query Mode are available in Fast Mode.  
There are commands only available in Fast Mode, but they are often similar to their
Query Mode counterparts. For example, **J** in Fast Mode and **C-J** in Query Mode.

---

<i class='fa fa-arrow-up'></i> / **C-K**  
Move indicator up.

<i class='fa fa-arrow-down'></i> / **C-J**  
Move indicator down.

<i class='fa fa-arrow-left'></i> / **C-H**  
Select a bookmark.

<i class='fa fa-arrow-right'></i> / **C-L**  
Unselect a bookmark.

**C-A**  
Select all bookmarks in **current page**.

**C-S-A**  
Select all bookmarks.

**C-U**  
Go to last page.

**C-D**  
Go to next page.

**Selected** means at least one bookmark is selected.  
**Selected Bookmarks** refers to all selected bookmarks.  
**Current Bookmark** means the bookmark under indicator.

**Enter**  
If **Selected**, open **Selected Bookmarks** **in new tabs**, hide Lynn, and finally go to newly-opened tab which contains the last selected bookmark.  
Otherwise hide Lynn and open **Current Bookmark** **in a new tab**.

**S-Enter**  
Same as **Enter**, except all bookmarks are opened **in the background**, and Lynn is **not** closed.

**C-Enter**  
Same as **Enter**, except all bookmarks are opened **in a new Chrome window**.

**C-S-Enter**  
Same as **Enter**, except all bookmarks are opened **in a new incognito window**.

---

#### Query Mode
There is a small amount of commands only available in Query Mode, mostly to help you editing the query.  

---

**C-**<i class='fa fa-arrow-left'></i> / **C-**<i class='fa fa-arrow-right'></i>   
Set cursor to one word left/right.

**C-Backspace** / **C-Delete**  
Delete one word left/right of cursor.

**C-R**
If **Selected**, remove **Selected Bookmarks**.
Otherwise remove **Current Bookmark**.


---

#### Fast Mode
**You are not allowed to change the query in the console in Fast Mode.**  
As its name implies, doing things in Fast Mode is always faster!

---

**H** / **J** / **K** / **L**  
Same as **C-H** / **C-J** / **C-K** / **C-L** 

**A** / **S-A**  
Same as **C-A** / **C-S-A**

**U** / **D**  
Same as **C-U** / **C-D**

**O** / **S-O** / **C-O** / **C-S-O**  
Same as **Enter** / **S-Enter** / **C-Enter** / **C-S-Enter**, which are
also available in fast mode.

**C** / **Forward Slash** 
Go to Query Mode and clear console.

**I**  
Go to Query Mode to modify the query.

**S-I**  
Same as **I**, except cursor is placed in the beginning of query.

**R**  
Same as **C-R** in Query Mode.

---

**T**  
Add tags to a bookmark.  
![Add tag](asset/img/add_tag.png)
Go to **Add Tag Special Mode**, where you enter tags.  
Tags not starting with **#** or **@** will be ignored.  
Multiple tags separated by space.  
No dup tag allowed.  
If **Selected**, affect all selected bookmarks. Otherwise only affect current bookmark.

You can use **Esc** to abort during **Add Tag Special Mode**.  
**All commands which require further user inputs can be aborted by Esc, this is very
common in Command Mode, which is explained later.**

**S-T**  
Same as **T**, except tags on current bookmark will be put in the console, which 
users can modify to add/delete tags.  
If **Selected**, operate on tags common to all selected bookmarks

---

#### Command Mode
**You can change the query (actually command now) in the console in Command Mode.**  
**You can't open bookmarks in this mode.**  
Command Mode is designed to help users add bookmarks easily, use other advanced features, etc.  
All commands always begin with a semicolon like in Vim.  
In other modes, you can type semicolon to switch to Command Mode.  
After finishing your command, press **Enter** to comfirm.

---
**An example**  
In this page, you'd see the following:

**:a**
*Add current page as a new bookmark, with custom tags.*

To use this command, **Ctrl-B** to open Lynn, **semicolon** to switch to **Command Mode**.  
Enter **a**, which finishes the command **:a**, press **Enter**.  
Enter the tag you want to be associated with this bookmark.  
All tags must begin with **#** or **@**, and multiple tags are separated by space.  
When you are satisfied with the bookmark, press **Enter**.  
The bookmark will be saved with the tags you have input, and Lynn will go to **Query Mode**,
displaying the added bookmark.

---

**:a**
Add current page as a new bookmark, with custom tags.

**:am**
Add multiple bookmarks.  
All opened tabs will be displayed in a list. Use **C-H/J/K/L** to move the cursor and select
bookmarks you want to add.  
**Chrome pages like chrome://extensions will be ignored.**

**:aa**
Add all opened pages in the current Chrome window.  
**Chrome pages like chrome://extensions will be ignored.**

**:aA**
Add all opened pages in all Chrome windows.  
**Chrome pages like chrome://extensions will be ignored.**

**:al**  
Add the next clicked link to bookmark.  
After confirming **:al** by presssing **Enter**, Lynn will temporarily disappear.  
Click the link you want to add to bookmark, and Lynn will reappear.

**:as** | **:as -r**   
Add the selected links as new bookmarks, optionally to load names **r**emotely.  
When you have a page that contains many links in a list, you can use this feature to 
effectively save bookmarks.  
After confirming **:as** by pressing **Enter**, Lynn will temporarily disappear.
Left click, drag to select all links you want, release mouse.  
Then enter all the tags you want, and save by pressing **Enter**.

If the **-r** flag is present, like in command **:as -r**, Lynn will send requests to the 
bookmarks' urls and fetch the name from there, instead of using the name provided in the
current page.

Running **:as -r** on [awesome-python](https://github.com/vinta/awesome-python)

![Add selection](asset/img/add_selection.png)

**:md** | **:md -r**  
Output as markdown link.  
When **-r** flag is present and multiple tags are selected, output
the **r**eference style markdown, which looks like:  

> \[1\]: https://github.com/octref/lynn  
> \[2\]: https://octref.github.io/lynn

![Markdown-Github](asset/img/markdown_output.png)

Usage:  

1. In Query Mode, move indicator to bookmark you want to add as markdown,
or select multiple bookmarks.
2. **Tab** to command mode, use either **:md** or **:md -r**.
3. If there is only one bookmark, edit the input box content, which will be the Markdown link's
title.  
Press Enter. Lynn will then disappear.  
Now mouse-click the WritingPad / InputArea / Textarea / Or-whatever-they-call-that-**\<textarea\>**.  
The Markdown output will be appended to the end of the textarea.  
4. If multiple bookmarks are selected and **-r** flag is present, leave input box empty.  
Press enter. Click the textarea.
5. If multiple bookmarks are selected and **-r** flag is not there, enter link titles separated by commas.  
![Markdown](asset/img/markdown.png)
Press Enter. Click the textarea.

---

#### Session
Session is very useful for:

- Temporarily storing some webpages to open later, but do not intend to add them as bookmarks.
- Adding related bookmarks as a group to open together.

**Open session**

- Input ":tmp" & press Enter to open session "tmp" and so forth. 
- S-Enter / C-Enter / C-S-Enter also works for sessions.
- In Query Mode, use "$ + sessionName* to quickly display & open bookmarks in sessions.
- You can check stored session at Option page of Lynn at chrome://extensions

**:s**  
Store all tabs in current Chrome window into a session.  
**Chrome pages like chrome://extensions will be ignored.**

**:S**  
Store all tabs in all Chrome windows into a session.  
**Chrome pages like chrome://extensions will be ignored.**

**:rs**  
Remove a session by name.  
Use autocomplete as you type the name.  
