<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:s="http://purl.oclc.org/dsdl/schematron"
                version="2.0">


  <!-- $Id: svrl2txt.xsl 5584 2009-11-24 12:14:07Z gerrit $ -->

  <xsl:output encoding="UTF-8" method="text"/>

  <xsl:template match="/">
    <xsl:text>&#xa;</xsl:text>
    <xsl:choose>
      <xsl:when test="//svrl:failed-assert">
        <xsl:value-of select="distinct-values(//svrl:active-pattern/@document)"/>
        <xsl:for-each-group select="//svrl:failed-assert" group-by="preceding-sibling::svrl:active-pattern[1]/@id">
          <xsl:variable name="active-pattern" select="//svrl:active-pattern[@id = current-grouping-key()]" as="node()"/>
          <xsl:text>  
  ID:         </xsl:text>
          <xsl:value-of select="$active-pattern/@id" />
          <xsl:if test="$active-pattern/@name ne $active-pattern/@id">
            <xsl:text>  
  title:      </xsl:text>
            <xsl:value-of select="$active-pattern/@name"/>
          </xsl:if>
          <xsl:text>  
  test:       </xsl:text>
          <xsl:value-of select="current-group()[1]/@test"/>
          <xsl:for-each select="current-group()">
            <xsl:text>
    location: </xsl:text>
            <xsl:value-of select="@location"/>
            <xsl:text>
     message: </xsl:text>
            <xsl:value-of select="svrl:text"/>
          </xsl:for-each>
        </xsl:for-each-group>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>OK: </xsl:text>
        <xsl:value-of select="distinct-values(//svrl:active-pattern/@document)"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

</xsl:stylesheet>