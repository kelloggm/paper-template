This repository contains the template that I use for new research papers. The most important parts
are the `Makefile` (which contains a number of useful rules) and `macros.tex` (which contains a number
of useful macros, such as `\<`, that you should familiarize yourself with and use as appropriate. The
main file (`paper.tex`) also includes packages that we almost always need, such as `cleverref`.

## How to use

You can use this repository to create a new paper. To do so, follow these steps:
1. use GitHub to create a new copy of this repository (this is a template repository).
Name it after the topic of the paper, with `-paper` appended to end. For example,
the RLC paper (FSE 2021) is `resource-leak-paper`. Call this new name $NAME for the rest
of these instructions.
2. run `sed -i "s/paper/$NAME/g" Makefile` (on a Mac, this must be `gsed`)
3. run `sed -i "s/paper.tex/$NAME.tex/g" .github/workflows/ci.yaml` (on a Mac, this must be `gsed`)
4. run `mv paper.tex $NAME.tex`
5. ensure that the resulting paper builds
6. commit your changes and start writing!

## Useful commands

Here are some of the useful commands in the `Makefile`:
* `make`: this will build the paper
* `make $NAME-notodos.pdf`: this will build the paper with todos disabled (suitable for submission)
* `make martin`: this will build the paper and then open it (using the system's `open` command) for viewing
(it is named this because when I was a PhD student, I was the only one of my co-authors who was interested
in this functionality)
* `make onefile.tex`: builds a version of the paper in a single `.tex` file, suitable for submission
to the publisher's website (i.e., with comments removed, etc.)

Here are some of the most useful macros defined in `macros.tex`:
* `\<`: use this short macro for in-line code snippets, e.g., `\<@Nullable String>`
* `\trule`: use this macro for small type rules
* `\etc`, `\eg`, and `\ie` for common Latin phrases that are easy to mess up
* others
