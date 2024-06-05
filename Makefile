# Put user-specific changes in your own Makefile.user.
# Make will silently continue if that file does not exist.
-include Makefile.user

NAME	:= paper

all: ${NAME}.pdf

.PRECIOUS: %.pdf
${NAME}.pdf: plume-bib-update pdf-ignore-undefined
  # Fail the build if there are undefined references or citations.
	@ ! grep "Warning: There were undefined references." "${NAME}.log"
	@ ! grep "Warning: There were undefined citations." "${NAME}.log"

.PHONY: pdf-ignore-undefined
pdf-ignore-undefined:
	latexmk -bibtex -pdf -shell-escape -synctex=1 -interaction=nonstopmode -f "${NAME}.tex"

${NAME}-notodos.pdf: pdf-ignore-undefined
	pdflatex -shell-escape "\def\notodocomments{}\input{${NAME}}"
	pdflatex -shell-escape "\def\notodocomments{}\input{${NAME}}"
	cp -pf ${NAME}.pdf $@

${NAME}-long.pdf: pdf-ignore-undefined
	pdflatex -shell-escape "\def\createlongversion{}\input{${NAME}}"
	pdflatex -shell-escape "\def\createlongversion{}\input{${NAME}}"
	cp -pf ${NAME}.pdf $@

${NAME}-long-notodos.pdf: pdf-ignore-undefined
	pdflatex -shell-escape "\def\createlongversion{}\def\notodocomments{}\input{${NAME}}"
	pdflatex -shell-escape "\def\createlongversion{}\def\notodocomments{}\input{${NAME}}"
	cp -pf ${NAME}.pdf $@

# You will upload onefile.zip to the publisher website after acceptance.
onefile.zip: onefile.tex
	zip onefile.zip onefile.tex acmart.cls ACM-Reference-Format.bst
# The latex-process-inputs program is part of https://github.com/plume-lib/plume-scripts,
# which is a collection of useful scripts. I recommend adding it to your PATH.
onefile.tex:
	latex-process-inputs ${NAME}.tex > onefile.tex

# This target creates:
#   https://homes.cs.washington.edu/~mernst/tmp678/${NAME}.pdf
web: ${NAME}-notodos.pdf
	cp -pf $^ ${HOME}/public_html/tmp678/${NAME}.pdf

view: ${NAME}.pdf
	open $<

ispell: spell
spell:
	for file in `latex-process-inputs -list ${NAME}.tex`; do ispell $$file; done

# Count words in the abstract, which some conferences limit.
abs-words:
	grep -v 'Abstract' abstract.tex | egrep -v '^%' | wc -w

plume-bib:
ifdef PLUMEBIB
	ln -s ${PLUMEBIB} $@
else
	git clone --filter=blob:none https://github.com/mernst/plume-bib.git
endif
.PHONY: plume-bib-update
# Even if the plume-bib-update target fails, it does not terminate the make job.
# However, to skip it, invoke make as:  make NOGIT=1 ...
plume-bib-update: plume-bib
ifndef NOGIT
ifneq (,$(wildcard plume-bib/.git))
	-(cd plume-bib && GIT_TERMINAL_PROMPT=0 git pull && make)
endif
endif

.PHONY: tags
TAGS: tags
tags:
	etags `latex-process-inputs -list ${NAME}.tex`

clean:
	latexmk -C "${NAME}.tex"
