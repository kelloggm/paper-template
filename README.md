This repository contains a template for research papers. The most important
parts are the `Makefile` (which contains a number of useful rules) and
`macros.tex` (which contains a number of useful macros, such as `\<`, that you
should familiarize yourself with and use as appropriate). The main file
(`paper.tex`) also includes commonly-used packages, such as `cleverref`.

## How to use

You can use this repository to create a new paper. To do so, follow these steps:
1. use GitHub to create a new, private copy of this repository (this is a template repository).
Name it after the topic of the paper, with `-paper` appended to end. For example,
the RLC paper (FSE 2021) is `resource-leak-paper`. Call this new name $NAME for the rest
of these instructions.
2. run `sed -i "s/paper/$NAME/g" Makefile .gitignore` (on a Mac, this must be `gsed`)
    * To install `gsed` on macOS, you can run `brew install gnu-sed` if you use
      Homebrew.
3. run `git mv paper.tex $NAME.tex`
4. ensure that the resulting paper builds:  run `make`
5. commit your changes and start writing!

Do not add your experimental scripts or anything else that might need to go into
your paper's artifact to the paper repository. Generally, you want to keep the paper
repository private (no one else needs to see your todo comments!), but you will eventually
want to make the artifact repository public (usually, it can be public from the start).

## Useful Makefile targets

Here are some of the useful commands in the `Makefile`:
* `make`: this will build the paper
* `make $NAME-notodos.pdf`: this will build the paper with todos disabled (suitable for submission)
* `make view`: this will build the paper and then open it (using the system's `open` command) for viewing
* `make onefile.tex`: builds a version of the paper in a single `.tex` file, suitable for submission
to the publisher's website (i.e., with comments removed, etc.)

## Useful LaTeX macros

Here are some of the most useful macros defined in `macros.tex`:
* `\<`: use this short macro for in-line code snippets, e.g., `\<@Nullable String>`
* `\trule`: use this macro for small type rules
* `\eg`, and `\ie` for common Latin phrases that are easy to mess up
* the `\researchquestions` environment for stylized research questions
* others
