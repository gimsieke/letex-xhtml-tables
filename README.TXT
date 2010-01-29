* PREREQUISTITES

  You need an XSLT 2 processor, for example saxon 9.2 HE,
  http://saxon.sourceforge.net/#F9.1B

  In the following, I assume that there is a saxon front-end script
  called 'saxon'.

  My cygwin 'saxon' command looks like this, for example:

#!/bin/bash
java \
   -Xmx1024m \
   net.sf.saxon.Transform \
   -x:org.apache.xml.resolver.tools.ResolvingXMLReader \
   -y:org.apache.xml.resolver.tools.ResolvingXMLReader \
   -r:org.apache.xml.resolver.tools.CatalogResolver \
   -l \
   -expand:off \
   -opt:9 \
   -strip:none \
   "$@"

  There is some catalog configuration involved, which I can make
  available on request (it saves fetching the XHTML DTD over the
  Internet again and again, thus reducing processing time).


  For generating the formula images, you need ImageMagick with PDF
  support (through ghostscript, I think). I installed IM 6.4 on cygwin
  and it worked out of the box. The generated image conversion
  script/batch file assumes that IM's 'convert' tool is available in
  the path.


* CHECKING XHTML MARKUP

  * dubbel-xhtml.sch.xsl

    An XSLT 2.0 stylesheet generated from a Schematron schema. 

    Sample invocation (cygwin or Linux, where you can pipe):

    saxon -xsl:dubbel-xhtml.sch.xsl -s:f01t18.xhtml | \
      saxon -s:- -xsl:svrl2txt.xsl

    (As above in the saxon frontend script, the backslash indicates
    line continuation.)

    You may as well create an intermediary file and use a two-step
    process:

    saxon -xsl:dubbel-xhtml.sch.xsl -s:f01t18.xhtml -o:tmp.svrl.xml
    saxon -xsl:svrl2txt.xsl -s:tmp.svrl.xml

    'svrl2txt.xsl' will present a more readable output than plain
    svrl, which is the default Schematron output.

    For completeness, I've included the Schematron source file 
    dubbel-xhtml.sch. There may be some more rules necessary.

    Please note that Schematron validation is not meant as a
    replacement for DTD or Schema validation of the XHTML data. It is
    rather a project-specific refinement of the basic validation.


* Generating LaTeX files for the formulas, 
  and a batch file to generate PNGs

  * extract-latex-formulas.xsl

    Sample invocation:

    saxon -xsl:extract-latex-formulas.xsl -s:data/f01t18.xhtml  style=unix

    style=win is the default, so

    saxon -xsl:extract-latex-formulas.xsl -s:data/f01t18.xhtml

    will create f01t18.bat. I didn't test the .bat file. The unixy .sh 
    file worked on cygwin.


Please feel free to customize the scripts for your needs, but please
do not redistribute them without our permission.

