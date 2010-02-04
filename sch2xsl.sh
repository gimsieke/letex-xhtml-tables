#!/bin/bash

SCHEMATRONDIR=file:///c://cygwin/lib/Schematron

saxon -versionmsg:off -xsl:$SCHEMATRONDIR/iso_abstract_expand.xsl -s:$1  \
 | saxon -versionmsg:off -xsl:$SCHEMATRONDIR/iso_svrl_for_xslt2.xsl -s:- -o:`basename $1`.xsl full-path-notation=3
# phase="err"