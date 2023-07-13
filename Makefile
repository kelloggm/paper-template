# Put user-specific changes in your own Makefile.user.
# Make will silently continue if that file does not exist.
-include Makefile.user

NAME	:= paper
BIBFILE := local.bib

# To regenerate list of files:  latex-process-inputs --makefilelist paper.tex
# The latex-process-inputs program is part of https://github.com/plume-lib/plume-scripts,
# which is a collection of useful scripts. I recommend adding it to your PATH.
TEX_FILES = \
paper.tex \
macros.tex \
abstract.tex \
introduction.tex \
technique.tex \
implementation.tex \
evaluation.tex \
limitations.tex \
relatedwork.tex

all: ${NAME}.pdf

.PRECIOUS: %.pdf
${NAME}.pdf: ${TEX_FILES}
	${MAKE} plume-bib-update
# Possibly add "-shell-escape" argument.
	latexmk -bibtex -pdf -interaction=nonstopmode -f "${NAME}.tex"

${NAME}-notodos.pdf: ${NAME}.pdf
	pdflatex "\def\notodocomments{}\input{${NAME}}"
	pdflatex "\def\notodocomments{}\input{${NAME}}"
	cp -pf ${NAME}.pdf $@

# Upload onefile.zip to the publisher website
onefile.zip: onefile.tex
	zip onefile.zip onefile.tex acmart.cls ACM-Reference-Format.bst
onefile.tex: $(filter-out onefile.tex, $(wildcard *.tex))
	latex-process-inputs ${NAME}.tex > onefile.tex

# This target creates:
#   https://homes.cs.washington.edu/~mernst/tmp678/${NAME}.pdf
web: ${NAME}-notodos.pdf
	cp -pf $^ ${HOME}/public_html/tmp678/${NAME}.pdf
.PHONY: ${NAME}-singlecolumn.pdf ${NAME}-notodos.pdf

view: ${NAME}.pdf
	open $<

ispell: spell
spell:
	for file in ${TEX_FILES}; do ispell $$file; done

# Count words in the abstract, which some conferences limit.
abs-words:
	grep -v 'Abstract' abstract.tex | egrep -v '^%' | wc -w

plume-bib:
ifdef PLUMEBIB
	ln -s ${PLUMEBIB} $@
else
	git clone https://github.com/mernst/plume-bib.git
endif
.PHONY: plume-bib-update
plume-bib-update: plume-bib
# Even if this command fails, it does not terminate the make job.
# However, to skip it, invoke make as:  make NOGIT=1 ...
ifndef NOGIT
	-(cd plume-bib && git pull && make)
endif

TAGS: tags
tags:
	etags `latex-process-inputs -list ${NAME}.tex`

clean:
	latexmk -C '${NAME}.tex'
