letex-xhtml-tables
==================

A collection of tools that enable digitization vendors to deliver
tables in a standardized manner.

* FEATURES

  - XHTML markup enables on-screen checking of digitized tables.
  - The permissible XHTML markup is heavily restricted using
    Schematron rules.
  - This enables automatic conversion to CALS or custom formats.
  - Math may be embedded as LaTeX in the form 
    <img src="ieq_basename_001.png" alt="$E=mc^2$ />
    This enables a preview in LaTeX format when the images have
    not been rendered yet.
  - This embedded markup may be rendered to PNGs by automatically
    generated scripts and LaTeX wrappers.


* PREREQUISTITES

  * saxon

    You need a Java-based XSLT 2 processor, for example saxon 9.2 HE,
    http://saxon.sourceforge.net/#F9.1B
    According to Stefan Krause, Altova should work, too.
  
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


  * Schematron

    Download http://www.schematron.com/tmp/iso-schematron-xslt2.zip
    and extract its contents to a directory (sch2xsl.sh below expects
    it to be C:\cygwin\lib\Schematron).

    We have attached a precompiled XSLT for convenience. Therefore you
    may skip this prerequisite.


* CHECKING XHTML MARKUP

  * Generating XSLT from Schematron

    The Unix shell script 

    sch2xsl.sh letex-xhtml-table.sch

    will generate letex-xhtml-table.sch.xsl from letex-xhtml-table.sch.

    Please adapt the script to your own need (e.g., make a .bat out of
    it if you are using Windows).

    We have attached a generated letex-xhtml-table.sch.xsl for
    convenience. This means that you can skip this step.


  * letex-xhtml-table.sch.xsl

    An XSLT 2.0 stylesheet generated from a Schematron schema. 

    Sample invocation (cygwin or Linux, where you can pipe):

    saxon -xsl:letex-xhtml-table.sch.xsl -s:sample/f01t18.xhtml | \
      saxon -s:- -xsl:svrl2txt.xsl

    (As above in the saxon frontend script, the backslash indicates
    line continuation.)

    You may as well create an intermediary file and use a two-step
    process:

    saxon -xsl:letex-xhtml-table.sch.xsl -s:f01t18.xhtml -o:tmp.svrl.xml
    saxon -xsl:svrl2txt.xsl -s:tmp.svrl.xml

    'svrl2txt.xsl' will present a more readable output than plain
    svrl, which is the default Schematron output.

    For completeness, I've included the Schematron source file 
    letex-xhtml-table.sch. There may be some more rules necessary.

    Please note that Schematron validation is not meant as a
    replacement for DTD or Schema validation of the XHTML data. It is
    rather a project-specific refinement of the basic validation.


  * If there are findings

    The report for the included table sample/u01t14.xhtml should look
    like:

file:/C:/cygwin/home/gerrit/letex-xhtml-tables/sample/u01t14.xhtml  
  ID:         TableAllowedAttributes  
  test:       every $a in @* satisfies (name($a) = tokenize('frame rules', '\s+'))
    location: /html/body/table
     message: Only attributes (frame rules) are allowed in this context. Found: border=0  
  ID:         RowAllowedElements  
  test:       every $c in * satisfies (node-name($c) = (for $n in tokenize('td', '\s+') return QName($ns-uri, $n)))
    location: /html/body/table/thead/tr[4]
     message: Only elements (td) are allowed in this context. Found: th  
  ID:         InlineMarkupExclusions  
  test:       not(.//*[node-name(.) = node-name(current())])
    location: /html/body/table/thead/tr[4]/th/p/i
     message: Element html:sub|html:sup|html:b|html:i must not contain itself as descendant.  
  ID:         MarkupThatShouldBeLaTeX  
  title:      Text and images that look like equations  
  test:       ends-with(@src, '.png')
    location: /html/body/table/tbody/tr[14]/td[4]/p/img
     message: If this is a LaTeX inline equation, please refer to a PNG @src file whose name ends with '.png'
    location: /html/body/table/tbody/tr[14]/td[5]/p
     message: Please consider using LaTeX markup for equations (for proper spacing, etc.)
    location: /html/body/table/tbody/tr[14]/td[6]/p
     message: Please consider using LaTeX markup for equations (for proper spacing, etc.)
    location: /html/body/table/tbody/tr[14]/td[7]/p
     message: Please consider using LaTeX markup for equations (for proper spacing, etc.)
    location: /html/body/table/tbody/tr[14]/td[8]/p
     message: Please consider using LaTeX markup for equations (for proper spacing, etc.)
    location: /html/body/table/tbody/tr[14]/td[9]/p
     message: Please consider using LaTeX markup for equations (for proper spacing, etc.)  
  ID:         NonEquationImagesMustBePresent  
  title:      Non-equation images must be present  
  test:       letex:file-exists( resolve-uri( @src, $base-uri ) )
    location: /html/body/table/tbody/tr[14]/td[3]/p/img
     message: The non-equation image u01t14_002.jpg must be present at its @src location.

    It is desirable that the results are being patched into the XHTML
    file, for in-place diagnostic messages. Until we have implemented
    this, you may paste the locations into the search form of an
    application that is able to perform XPath search, such as Philip
    Fearon's SketchPath (http://pgfearo.googlepages.com/).


* GENERATING LATEX FILES FOR THE FORMULAS, 
  and a batch file to generate PNGs

  * extract-latex-formulas.xsl

    Sample invocation:

    saxon -xsl:extract-latex-formulas.xsl -s:data/f01t18.xhtml  style=unix

    style=win is the default, so

    saxon -xsl:extract-latex-formulas.xsl -s:data/f01t18.xhtml

    will create f01t18.bat. I didn't test the .bat file. The unixy .sh 
    file worked on cygwin.


* TO DO

  * Check correctness of &#x2007; (Figure Space) indentation in numeric
    columns.

  * Visualize the findings in the HTML (i.e., patch the HTML with
    Schematron comments.



These files are made available subject to the terms of
the GNU Lesser General Public License Version 2.1

Author:
Gerrit Imsieke, le-tex publishing services GmbH, Leipzig
http://www.le-tex.de/
Thanks to Stefan Krause (stf at snafu dot de) for the file-exists
function.


GNU Lesser General Public License Version 2.1
=============================================
Copyright (C) 2010, le-tex publishing services GmbH

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

