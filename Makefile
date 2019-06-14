USE_PDFLATEX =	yes
NAME =		perform-slides
TEXSRCS	=	perform-slides.tex
CLEAN_FILES =	${NAME:=.nav} ${NAME:=.snm}
# make does not support : in file name, it is a variable modifier
# latex does not support . in file name, it is a suffix
GNUPLOTS =	2019-02-04T15:10:35Z tcp - \
		2019-03-19T14:50:23Z tcp 7 \
		2019-03-20T00:44:00Z tcp 7 \
		2019-03-20T17:37:52Z tcp 7 \
		2019-02-01T00:35:28Z tcp - \
		2019-04-30T19:11:10Z tcp 1 \
		2019-01-15T01:56:26Z tcp - \
		2019-04-24T16:19:44Z tcp - \
		2019-05-01T21:26:58Z tcp - \
		2019-06-11T12:11:57Z udp -
HTMLS =		2019-04-16T00-00-00Z--2019-04-17T00-00-00Z

.for d t n in ${GNUPLOTS}

p =		gnuplot/${d:S/:/-/g}-$t${n:N-:S/^/_/}
TEXSRCS +=	gnuplot/${d:S/:/-/g}-$t${n:N-:S/^/_/}.tex
OTHER +=	gnuplot/${d:S/:/-/g}-$t${n:N-:S/^/_/}.pdf
CLEAN_FILES +=	gnuplot/${d:S/:/-/g}-$t${n:N-:S/^/_/}.{tex,eps,pdf}

$p.tex: gnuplot.pl Buildquirks.pm plot.gp test-$t.data
	mkdir -p ${@:H}
	perl gnuplot.pl -D $d -T $t ${n:N-:S/^/-N /} $@

$p.eps: $p.tex

$p.pdf: $p.eps
	epstopdf ${@:.pdf=.eps}

.endfor

.for h in ${HTMLS}

OTHER +=	html/$h.pdf
CLEAN_FILES +=	html/$h.pdf

html/$h.pdf: html/$h.html
	wkhtmltopdf file://${.CURDIR}/html/$h.html html/$h.pdf

.endfor

.include </usr/local/share/latex-mk/latex.mk>
