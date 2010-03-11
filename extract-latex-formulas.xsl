<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:letex="http://www.le-tex.de/namespace"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  version="2.0">

  <xsl:output 
    method="text"
    encoding="US-ASCII"/>

  <xsl:param name="style" select="'win'" /><!-- 'win' or 'unix' -->

  <letex:term-map>
    <entry name="script-ext">
      <translation lang="win">bat</translation>
      <translation lang="unix">sh</translation>
    </entry>
    <entry name="shebang-line">
      <translation lang="unix">#!/bin/bash</translation>
    </entry>
    <entry name="delete-files">
      <translation lang="win">del</translation>
      <translation lang="unix">rm -f</translation>
    </entry>
    <entry name="newline">
      <translation lang="win">&#xd;&#xa;</translation>
      <translation lang="unix">&#xa;</translation>
    </entry>
  </letex:term-map>

  <xsl:template match="/">
    <xsl:variable name="latex-images" select="//html:img[starts-with(@src, 'ieq_') and @alt]" as="element(html:img)*" />
    <xsl:variable name="srcdir" select="letex:dirname(document-uri(.))" />

    <xsl:for-each select="$latex-images">
      <xsl:result-document href="{$srcdir}{letex:basename(@src, 'tex')}">
\documentclass{article}
\usepackage{amsmath}
\thispagestyle{empty}
\begin{document}
<xsl:value-of select="@alt"/>
\end{document}
      </xsl:result-document>
    </xsl:for-each>
    <xsl:choose>
      <xsl:when test="$latex-images">
        <xsl:message><xsl:value-of select="document-uri(.)"/> contains <xsl:value-of select="count($latex-images)"/> formula images.
        </xsl:message>
        <xsl:variable name="script-lines">
          <line>
            <xsl:value-of select="letex:lookup-term('shebang-line', $style)"/>
          </line>
          <xsl:for-each select="$latex-images">
            <line>
              <xsl:text>pdflatex </xsl:text>
              <xsl:value-of select="letex:basename(current()/@src, 'tex')"/> 
            </line>
            <line>
              <xsl:text>convert -density 120 -trim </xsl:text>
              <xsl:value-of select="letex:basename(current()/@src, 'pdf')"/>
              <xsl:text> -transparent white </xsl:text>
              <xsl:value-of select="letex:basename(current()/@src, 'png')"/> 
            </line>
            <line>
              <xsl:value-of select="letex:lookup-term('delete-files', $style)"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="for $ext in ('pdf', 'tex', 'log', 'aux') return letex:basename(current()/@src, $ext)"/>
            </line>
          </xsl:for-each>
        </xsl:variable>
        <xsl:result-document href="{letex:basename(document-uri(.), letex:lookup-term('script-ext', $style))}">
          <xsl:for-each select="$script-lines/line">
            <xsl:value-of select="current()"/>
            <xsl:value-of select="letex:lookup-term('newline', $style)"/>
          </xsl:for-each>
        </xsl:result-document>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message><xsl:value-of select="document-uri(.)"/> does not contain formula images.
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:function name="letex:basename" as="xs:string">
    <xsl:param name="file-uri" as="xs:string" />
    <xsl:param name="new-extension" as="xs:string?" />
    <xsl:value-of select="replace($file-uri, '\.\w+$', if ($new-extension) then concat('.', $new-extension) else '')"/>
  </xsl:function>

  <xsl:function name="letex:dirname" as="xs:string">
    <xsl:param name="file-uri" as="xs:string" />
    <xsl:value-of select="replace($file-uri, '[^/]+$', '')"/>
  </xsl:function>

  <xsl:function name="letex:lookup-term" as="xs:string">
    <xsl:param name="key" as="xs:string" />
    <xsl:param name="style" as="xs:string" />
    <xsl:value-of select="document('')//letex:term-map/entry[@name=$key]/translation[@lang=$style]" />
  </xsl:function>

</xsl:stylesheet>
