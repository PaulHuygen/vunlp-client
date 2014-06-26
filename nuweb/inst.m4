m4_dnl
m4_dnl Titles
m4_dnl
m4_define(m4_progname, `vunlpclient')m4_dnl
m4_define(m4_doctitle, `Client-script for VUnlp system')m4_dnl
m4_define(m4_docdate, `\today \\ m4_time_of_day~h.')m4_dnl
m4_define(m4_author, `Paul Huygen <paul.huygen@@huygen.nl>')m4_dnl
m4_define(m4_subject, `Vunlp Lisa client')m4_dnl
m4_dnl
m4_dnl Locations of programs and system-dependent definitions
m4_dnl
m4_define(m4_mkportbib, `/home/paul/bin/mkportbib')m4_dnl
m4_define(m4_printpdf, `lpr '$1`.pdf')m4_dnl
m4_define(m4_viewpdf, `evince '$1`.pdf')m4_dnl
m4_define(m4_latex, `pdflatex '$1)m4_dnl
m4_define(m4_nuwebbinary, `/usr/local/bin/nuweb')m4_dnl
m4_define(m4_nuweb, `nuweb')m4_dnl
m4_dnl
m4_dnl Paths and URL's
m4_dnl
m4_dnl
m4_define(m4_aprojroot, `m4_regexp(m4_esyscmd(pwd), `\(^[a-zA-Z0-9/]+\)/nuweb$', `\1')')m4_dnl
m4_define(m4_projroot, `..')m4_dnl
m4_define(m4_defaulturl, `localhost:8090')m4_dnl
m4_dnl m4_define(m4_defaulturl, `http://labs.vu.nl/ws')m4_dnl
m4_dnl
m4_dnl    subdirs 
m4_dnl
m4_define(m4_abindir, m4_aprojroot`/bin')m4_dnl     Binaries
m4_define(m4_bindir, m4_projroot`/bin')m4_dnl     Binaries
m4_dnl
m4_dnl internal URL's and their templates
m4_dnl 
m4_dnl
m4_dnl Commands
m4_dnl
m4_define(m4_printpdf, `lpr '$1`.pdf')m4_dnl
m4_dnl
m4_dnl bibliography (bib files that can be reached with kpesewhich, without .bib extension)
m4_dnl
m4_define(m4_bibliographies, `litprog')m4_dnl
m4_dnl
m4_dnl external URL's
m4_dnl 
m4_define(m4_nuwebURL, `nuweb.sourceforge.net')m4_dnl
m4_dnl
m4_dnl Miscellaneous
m4_dnl
m4_dnl
m4_dnl max times to compile with LaTeX.
m4_dnl
m4_define(m4_maxtexloops, `10')m4_dnl
m4_dnl
m4_dnl (style) things that probably do not have to be modified
m4_dnl
m4_changequote(`<!',`!>')m4_dnl
m4_define(m4_header, <!m4_esyscmd(date +'%Y%m%d at %H%Mh'| tr -d '\012'): Generated by nuweb from a_!>m4_progname<!.w!>)
m4_define(m4_time_of_day, <!m4_esyscmd(date +'%H:%M'| tr -d '\012')!>)m4_dnl
m4_define(m4_index4ht, <!tex '\def\filename{{!>m4_progname<!}{idx}{4dx}{ind}} \input idxmake.4ht'!>)m4_dnl
m4_define(m4_nuwebbindir, <!m4_projroot!>/nuweb/bin)m4_dnl