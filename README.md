# Tabv for Vim

Easily open relevant groupings of files in Vim. This plugin is currently
simplistic and hacky. I am developing it slowly over time. If you start
using it please let me know what you need from it by submitting issues.
And if you by some wild chance you actually find this useful you can always
[![endorse](https://api.coderwall.com/kazark/endorsecount.png)](https://coderwall.com/kazark)
me.

I use it along with [The NERD tree](https://github.com/scrooloose/nerdtree) and
[CtrlP.Vim](https://github.com/kien/ctrlp.vim) in order to easily call up files
from within a project and make working in Vim more like working in an IDE. Both
those plugins are far more mature and powerful than this one is, plus the guys
who wrote them are way better with VimL than I am. I recommend them both above
this one.

## Current behavior
### Open a tab and populate it with related files
It is designed to be used through the `:Tabv` command, which will guess which of
the supported commands to use (currently, it will try to guess whether it is
JavaScript, and if it is not, will fall back on C++).

However, if you aren't as braindead as I am, you can you the specific commands
directly. Currently it supports C++ through `:Tabcxxv` and JavaScript through
`:Tabjsv`. The C++ command will bring up the header file, the source file, and
the unit tests. The JavaScript command will bring up the script and its unit
tests. The locations and extension of these files can be configured through
global variables.

Example uses:

    :Tabcxxv Channel

![Tabcxxv](http://i.imgur.com/vOyeKyD.png)

    :Tabcxxv Router<>

![Tabcxxv<>](http://i.imgur.com/7eR41hi.png)

    :Tabjsv tokens

![Tabjsv](http://i.imgur.com/sOqu4Nx.png)

### Open relevant files for already opened file in same tab
Will attempt to figure out where the unit tests for the current buffer are and
open them in a vertically split window:

    :Vsunittests

Note: initial implementation of this is very crappy.

## Desired future behavior
+ Implement for more languages (if you have a language you would like to see
  implemented, let me know; I'm working on features on an as-needed basis)
+ Have functions make more intelligent attempts to find the files you want
  - Based on makefile for C++ projects
  - Improved `Gruntfile`-based guessing algorithm
    + Only guess the paths once per Vim session
    + Better scraping algorithm
+ Make `:Vsunittests` work for C++ and make it use `Gruntfile`-based guessing
  algorithm
