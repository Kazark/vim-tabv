# Tabv for Vim [![GitHub version](https://badge.fury.io/gh/kazark%2Fvim-tabv.svg)](http://badge.fury.io/gh/kazark%2Fvim-tabv)

Easily open relevant groupings of files in Vim. This plugin is currently
simplistic and hacky. I am developing it slowly over time. If you start using it
please let me know what you need from it by submitting issues.

I use it along with [The NERD tree](https://github.com/scrooloose/nerdtree) and
[CtrlP.Vim](https://github.com/kien/ctrlp.vim) in order to easily call up files
from within a project and make working in Vim more like working in an IDE. Both
those plugins are far more mature and powerful than this one is, plus the guys
who wrote them are way better with VimL than I am. I recommend them both above
this one, but they can be used to complement each other.

## Open a tab and populate it with related files
The main command is `:Tabv`. It takes one argument, which is the "root" or
"stem" of the set of files you want to open (see below for examples). It
attempts to guess the type of project you are working on and open the files
accordingly. Currently C#, C++, Python, JavaScript and Go are supported. A
variant of this command is `:Tvword`, which does the same thing but using the
word under cursor instead of a command-mode argument.

For C++ projects, it will bring up the header file, the source file, and the
unit tests. For JavaScript projects, the command will bring up the script and
its unit tests. The locations and extension of these files can be configured
through global variables.

Example in a C++ project:

    :Tabv Channel

![Tabv for C++](http://i.imgur.com/vOyeKyD.png)

Example in a C++ project, using the `<>` extension, which will cause only the
unit tests and header file to be loaded (not the source file; C++ templates do
no have source files):

    :Tabv Router<>

![Tabv<> for C++](http://i.imgur.com/7eR41hi.png)

Example for a JavaScript project:

    :Tabv tokens

![Tabv for JavaScript](http://i.imgur.com/TtEPlbQ.png)

The same command is available wrapped/aliased for use in shell environments
(Bash and PowerShell). For Bash, source the `tabv.sh` file in your `.bashrc`, or
for PowerShell source the `tabv.ps1` in your `$profile`. Two addition commands
are define in each environment: `vs` and `sp`, which will open two files split
vertically or horizontally.

## Open relevant files for already opened file in same tab
Will attempt to figure out where the unit tests for the current buffer are and
open them in a vertically split window:

    :Vsunittests

## Installation

I recommend installing with [Pathogen](https://github.com/tpope/vim-pathogen),
thus (you may need to `mkdir ~/.vim/bundle`):

    cd ~/.vim/bundle
    git clone https://github.com/Kazark/vim-tabv.git

_Note_: you may have to use `~\vimfiles` instead of `~/.vim` if you are on
Windows.

## Developer Notes

To run the specs, you will need [Vader](://github.com/junegunn/vader.vim)
installed as a Vim plugin. The from within the Tabv repository, do:

    cd specs
    vim +Vader*

this will run all the specs. For more information, see Vader's documentation.
