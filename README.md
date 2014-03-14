## Tabv for Vim

Easily open relevant groupings of files as a tab in Vim. This plugin is
currently very simplistic. I am hoping to develop it slowly over time.

### Current behavior
Currently it supports C++ through `:Tabcxxv` and JavaScript through `:Tabjsv`.
The C++ command will bring up the header file, the source file, and the unit
tests. The JavaScript command will bring up the script and its unit tests. The
locations and extension of these files can be configured through global
variables.

Example uses:

    :Tabcxxv Channel

![Tabcxxv](http://i.imgur.com/vOyeKyD.png)

    :Tabcxxv Router<>

![Tabcxxv<>](http://i.imgur.com/7eR41hi.png)

    :Tabjsv tokens

![Tabjsv](http://i.imgur.com/sOqu4Nx.png)

### Desired future behavior
+ Make `:Tabv` context-sensitive, i.e. make it guess the language.
+ Implement for more languages
+ Have functions make more intelligent attempts to find the files you want
