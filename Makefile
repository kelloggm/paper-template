all: paper.pdf

paper.pdf: bib-update
	latexmk -pdf -interaction=nonstopmode -f paper.tex

paper-notodos.pdf: paper.pdf
	pdflatex "\def\notodocomments{}\input{paper}"
	pdflatex "\def\notodocomments{}\input{paper}"
	cp -pf paper.pdf $@

# Upload onefile.zip to the publisher website
onefile.zip: onefile.tex
	zip onefile.zip onefile.tex acmart.cls ACM-Reference-Format.bst
onefile.tex: $(filter-out onefile.tex, $(wildcard *.tex))
	latex-process-inputs paper.tex > onefile.tex


# This target creates:
#   https://homes.cs.washington.edu/~mernst/tmp678/paper.pdf
web: paper-notodos.pdf
	cp -pf $^ ${HOME}/public_html/tmp678/paper.pdf
.PHONY: paper-singlecolumn.pdf paper-notodos.pdf

martin: paper.pdf
	open $<

# export BIBINPUTS ?= .:bib
plume-bib:
ifdef PLUMEBIB
	ln -s ${PLUMEBIB} $@
else
	git clone https://github.com/mernst/plume-bib.git
endif
.PHONY: plume-bib-update
bib-update: plume-bib
# Even if this command fails, it does not terminate the make job.
# However, to skip it, invoke make as:  make NOGIT=1 ...
ifndef NOGIT
	-(cd plume-bib && make)
endif

TAGS: tags
tags:
	etags `latex-process-inputs -list paper.tex`

## TODO: this should not delete ICSE2020-submission.pdf
clean:
	rm -f *.bbl *.aux *~ paper.pdf *.blg *.log TAGS
