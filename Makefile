USE_PDFLATEX =	yes
NAME =		perform-slides
TEXSRCS	=	perform-slides.tex
# make does not support : in file name, it is a variable modifier
# latex does not support . in file name, it is a suffix
GNUPLOTS =	2019-02-04T15:10:35Z tcp 0 \
		2019-03-19T14:50:23Z tcp 7 \
		2019-03-20T00:44:00Z tcp 7 \
		2019-03-20T17:37:52Z tcp 7

.for d t n in ${GNUPLOTS}

p =		images/${d:S/:/-/g}-$t${n:N0:S/^/_/}
TEXSRCS +=	images/${d:S/:/-/g}-$t${n:N0:S/^/_/}.tex
OTHER +=	images/${d:S/:/-/g}-$t${n:N0:S/^/_/}.pdf
CLEAN_FILES +=	images/${d:S/:/-/g}-$t${n:N0:S/^/_/}.{tex,eps,pdf}

$p.tex:
	cd gnuplot && ./gnuplot.pl -D $d -T $t -N $n ../$@

$p.eps: $p.tex

$p.pdf: $p.eps
	epstopdf ${@:.pdf=.eps}

.endfor

.include </usr/local/share/latex-mk/latex.mk>
