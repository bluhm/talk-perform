USE_PDFLATEX =	yes
NAME =		perform-slides
TEXSRCS	=	perform-slides.tex
CLEAN_FILES =	${NAME:=.nav} ${NAME:=.snm}
# make does not support : in file name, it is a variable modifier
# latex does not support . in file name, it is a suffix
GNUPLOTS = \
    2019-02-04T15:10:35Z tcp - - - - - \
    2019-08-10T05:41:55Z tcp 7 1564614000 1564707600 3000000000 3500000000 \
    2019-08-10T00:26:05Z tcp 7 1564614000 1564707600 3000000000 3500000000 \
    2019-08-09T20:22:42Z tcp 7 1564614000 1564707600 3000000000 3500000000 \
    2019-08-09T16:57:09Z tcp 7 1564614000 1564707600 3000000000 3500000000 \
    2019-08-09T13:35:53Z tcp 7 1564614000 1564707600 3000000000 3500000000 \
    2019-08-09T08:58:58Z tcp 7 1564614000 1564707600 3000000000 3500000000 \
    2019-02-01T00:35:28Z tcp - - - - - \
    2019-04-30T19:11:10Z tcp 1 - - - - \
    2019-01-15T01:56:26Z tcp - - - - - \
    2019-04-24T16:19:44Z tcp - - - - - \
    2019-05-01T21:26:58Z tcp - - - - - \
    2019-06-11T12:11:57Z udp - - - - -
HTMLS =		2019-04-16T00-00-00Z--2019-04-17T00-00-00Z

.for d t n x X y Y in ${GNUPLOTS}

p =		gnuplot/${d:S/:/-/g}-$t
TEXSRCS +=	gnuplot/${d:S/:/-/g}-$t.tex
OTHER +=	gnuplot/${d:S/:/-/g}-$t.pdf
CLEAN_FILES +=	gnuplot/${d:S/:/-/g}-$t.{tex,eps,pdf}

$p.tex: gnuplot.pl Buildquirks.pm plot.gp test-$t.data
	mkdir -p ${@:H}
	perl gnuplot.pl -D $d -T $t ${n:N-:S/^/-N /} \
	    ${x:N-:S/^/-x /} ${X:N-:S/^/-X /} \
	    ${y:N-:S/^/-y /} ${Y:N-:S/^/-Y /} $@

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
