USE_PDFLATEX =	yes
NAME =		perform-slides
TEXSRCS	=	perform-slides.tex
CLEAN_FILES =	${NAME:=.nav} ${NAME:=.snm}
# make does not support : in file name, it is a variable modifier
# latex does not support . in file name, it is a suffix
GNUPLOTS =	2019-02-04T15:10:35Z tcp 0 \
		2019-03-19T14:50:23Z tcp 7 \
		2019-03-20T00:44:00Z tcp 7 \
		2019-03-20T17:37:52Z tcp 7 \
		2019-02-01T00:35:28Z tcp 0

.for d t n in ${GNUPLOTS}

p =		gnuplot/${d:S/:/-/g}-$t${n:N0:S/^/_/}
TEXSRCS +=	gnuplot/${d:S/:/-/g}-$t${n:N0:S/^/_/}.tex
OTHER +=	gnuplot/${d:S/:/-/g}-$t${n:N0:S/^/_/}.pdf
CLEAN_FILES +=	gnuplot/${d:S/:/-/g}-$t${n:N0:S/^/_/}.{tex,eps,pdf}

$p.tex: gnuplot.pl Buildquirks.pm plot.gp test-$t.data
	mkdir -p ${@:H}
	perl gnuplot.pl -D $d -T $t -N $n $@

$p.eps: $p.tex

$p.pdf: $p.eps
	epstopdf ${@:.pdf=.eps}

.endfor

.include </usr/local/share/latex-mk/latex.mk>
