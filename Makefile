# Put user-specific changes in your own Makefile.user.
# Make will silently continue if that file does not exist.
-include Makefile.user

NAME	:= paper

default: all

all: ${NAME}.pdf

.PRECIOUS: %.pdf
${NAME}.pdf: pdf-ignore-undefined
  # Fail the build if there are undefined references or citations.
	@ ! grep "Warning: There were undefined references." "${NAME}.log"
	@ ! grep "Warning: There were undefined citations." "${NAME}.log"

.PHONY: pdf-ignore-undefined
pdf-ignore-undefined: plume-bib-update
	latexmk -bibtex -pdf -shell-escape -synctex=1 -interaction=nonstopmode -f "${NAME}.tex"

.PHONY: notodos
notodos: ${NAME}-notodos.pdf
${NAME}-notodos.pdf: pdf-ignore-undefined
	pdflatex -shell-escape "\def\notodocomments{}\input{${NAME}}"
	pdflatex -shell-escape "\def\notodocomments{}\input{${NAME}}"
	cp -pf ${NAME}.pdf $@

.PHONY: long
long: ${NAME}-long.pdf
${NAME}-long.pdf: pdf-ignore-undefined
	pdflatex -shell-escape "\def\createlongversion{}\input{${NAME}}"
	pdflatex -shell-escape "\def\createlongversion{}\input{${NAME}}"
	cp -pf ${NAME}.pdf $@

.PHONY: long-notodos
long-notodos: ${NAME}-long-notodos.pdf
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

# To regenerate this list, run `make show-tex-files`
TEX_FILES=\
paper.tex \
macros.tex \
abstract.tex \
introduction.tex \
technique.tex \
implementation.tex \
evaluation.tex \
limitations.tex \
relatedwork.tex \
conclusion.tex

show-tex-files:
	@latex-process-inputs --makefilelist ${NAME}.tex

# This target creates:
#   https://homes.cs.washington.edu/~mernst/tmp678/${NAME}.pdf
web: ${NAME}-notodos.pdf
	cp -pf $^ ${HOME}/public_html/tmp678/${NAME}.pdf

view: ${NAME}.pdf
	open $<

# Choices: aspell, ispell, hunspell
# SPELLCHECK_I ?= aspell check
# SPELLCHECK_B ?= aspell list
SPELLCHECK_I ?= hunspell -p .local-dict.txt
SPELLCHECK_B ?= hunspell -l -p .local-dict.txt
spell:
	@echo "Use `make spelli` or `make spellb` for interactive or batch spell-checking."
spellcheck-interactive spell-interactive spelli:
	for file in ${TEX_FILES}; do \
          ${SPELLCHECK_I} -t $$file; \
        done
	@sort -o .local-dict.txt .local-dict.txt
spellcheck-batch spell-batch spellb:
	rm -rf misspelled-words.txt
	for file in ${TEX_FILES}; do \
          cat $$file | ${SPELLCHECK_B} -t | sort -u >> misspelled-words.txt; \
        done
	@sort -o .local-dict.txt .local-dict.txt
	@sort -u misspelled-words.txt
	@[ ! -s misspelled-words.txt ]

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
# Even if the plume-bib-update target fails, it does not terminate the make job.
# However, to skip it, invoke make as:  make NOGIT=1 ...
plume-bib-update: plume-bib
ifndef NOGIT
ifneq (,$(wildcard plume-bib/.git))
	-(cd plume-bib && GIT_TERMINAL_PROMPT=0 git pull && make)
endif
endif

plume-bib-copy:
	rm -f master.zip
	wget https://github.com/mernst/plume-bib/archive/refs/heads/master.zip
	rm -rf plume-bib-master
	unzip master.zip
	rm -rf plume-bib
	mv plume-bib-master plume-bib
	sed -i 's/^plume-bib$$/# plume-bib/' .gitignore
	rm -f master.zip

.PHONY: tags
TAGS: tags
tags:
	etags `latex-process-inputs -list ${NAME}.tex`

clean:
	latexmk -C "${NAME}.tex"
