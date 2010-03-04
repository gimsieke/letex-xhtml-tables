<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:letex="http://www.le-tex.de/namespace"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
<xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>

   <!--PHASES-->


<!--PROLOG-->
<xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>

   <!--XSD TYPES FOR XSLT2-->


<!--KEYS AND FUNCTIONS-->
<xsl:function xmlns:s="http://purl.oclc.org/dsdl/schematron" xmlns:java-file="java:java.io.File"
                 xmlns:java-uri="java:java.net.URI"
                 name="letex:file-exists"
                 as="xs:boolean">
      <xsl:param name="uri" as="xs:string?"/>
      <xsl:value-of select="java-file:exists(java-file:new(java-uri:new($uri)))"/>
   </xsl:function>

   <!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH -->
<xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>

   <!--MODE: GENERATE-ID-2 -->
<xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters--><xsl:template match="text()" priority="-1"/>

   <!--SCHEMA SETUP-->
<xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                              title="ISO Schematron rules for Dubbel Table Digitization content checking"
                              schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:text>Copyright (C) 2010, le-tex publishing services GmbH</svrl:text>
         <svrl:text>Version: 1.0.2 (2009-02-14)</svrl:text>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xhtml" prefix="html"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.le-tex.de/namespace" prefix="letex"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">HTML</xsl:attribute>
            <xsl:attribute name="name">Document type</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M10"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">HeadAllowedElements</xsl:attribute>
            <xsl:attribute name="name">HeadAllowedElements</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M11"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">Head</xsl:attribute>
            <xsl:attribute name="name">Meta info</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M12"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">LinkAllowedAttributes</xsl:attribute>
            <xsl:attribute name="name">LinkAllowedAttributes</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M13"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">HeadAllowedAttributeValues</xsl:attribute>
            <xsl:attribute name="name">HeadAllowedAttributeValues</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M14"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">BodyAllowedElements</xsl:attribute>
            <xsl:attribute name="name">BodyAllowedElements</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M15"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">TableAllowedElements</xsl:attribute>
            <xsl:attribute name="name">TableAllowedElements</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M16"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">TableAllowedAttributes</xsl:attribute>
            <xsl:attribute name="name">TableAllowedAttributes</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M17"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ColAllowedAttributes</xsl:attribute>
            <xsl:attribute name="name">ColAllowedAttributes</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M18"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ColAllowedAttributeValues</xsl:attribute>
            <xsl:attribute name="name">ColAllowedAttributeValues</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M19"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">RowAllowedElements</xsl:attribute>
            <xsl:attribute name="name">RowAllowedElements</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M20"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">RowAllowedAttributeValues</xsl:attribute>
            <xsl:attribute name="name">RowAllowedAttributeValues</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M21"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">CellAllowedElements</xsl:attribute>
            <xsl:attribute name="name">CellAllowedElements</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M22"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">CellAllowedAttributes</xsl:attribute>
            <xsl:attribute name="name">CellAllowedAttributes</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M23"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">CellAllowedAttributeValues</xsl:attribute>
            <xsl:attribute name="name">CellAllowedAttributeValues</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M24"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">CellAllowedAttributeValueNotAlsoOnRow</xsl:attribute>
            <xsl:attribute name="name">If there is already class="rule-below" on tr, don't allow this on td</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M25"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">OrderedListAllowedAttributes</xsl:attribute>
            <xsl:attribute name="name">OrderedListAllowedAttributes</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M26"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">OrderedListAllowedAttributeValues</xsl:attribute>
            <xsl:attribute name="name">OrderedListAllowedAttributeValues</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M27"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">UnorderedListsPlain</xsl:attribute>
            <xsl:attribute name="name">ul may have no attributes</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M28"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">InlineMarkupAllowedElements</xsl:attribute>
            <xsl:attribute name="name">InlineMarkupAllowedElements</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M29"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">InlineMarkupExclusions</xsl:attribute>
            <xsl:attribute name="name">InlineMarkupExclusions</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M30"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MarkupThatShouldBeLaTeX</xsl:attribute>
            <xsl:attribute name="name">Text and images that look like equations</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M31"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">EquationImageAllowedAttributes</xsl:attribute>
            <xsl:attribute name="name">EquationImageAllowedAttributes</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M32"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">NonEquationImagesMustBePresent</xsl:attribute>
            <xsl:attribute name="name">Non-equation images must be present</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M33"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">ISO Schematron rules for Dubbel Table Digitization content checking</svrl:text>
   <xsl:param name="ns-uri" select="'http://www.w3.org/1999/xhtml'"/>
   <xsl:param name="base-uri" select="document-uri(/)"/>

   <!--PATTERN HTMLDocument type-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Document type</svrl:text>

	  <!--RULE -->
<xsl:template match="/*" priority="1000" mode="M10">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="node-name(.) = QName($ns-uri, 'html')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="node-name(.) = QName($ns-uri, 'html')">
               <xsl:attribute name="id">root</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The root element must be 'html' in the namespace '<xsl:text/>
                  <xsl:value-of select="$ns-uri"/>
                  <xsl:text/>'. Found: '<xsl:text/>
                  <xsl:value-of select="local-name(.)"/>
                  <xsl:text/>' in the namespace '<xsl:text/>
                  <xsl:value-of select="namespace-uri-from-QName(node-name(.))"/>
                  <xsl:text/>'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="@*|*" mode="M10"/>
   </xsl:template>

   <!--PATTERN HeadAllowedElements-->


	<!--RULE -->
<xsl:template match="html:head" priority="1000" mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="html:head"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $c in * satisfies (node-name($c) = (for $n in tokenize('title link', '\s+') return QName($ns-uri, $n)))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $c in * satisfies (node-name($c) = (for $n in tokenize('title link', '\s+') return QName($ns-uri, $n)))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Only elements (<xsl:text/>
                  <xsl:value-of select="'title link'"/>
                  <xsl:text/>) are allowed in this context. Found: <xsl:text/>
                  <xsl:value-of select="distinct-values(*[not(string(node-name(.)) = tokenize('title link', '\s+'))]/node-name(.))"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="@*|node()" priority="-2" mode="M11">
      <xsl:apply-templates select="@*|*" mode="M11"/>
   </xsl:template>

   <!--PATTERN HeadMeta info-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Meta info</svrl:text>

	  <!--RULE -->
<xsl:template match="html:head" priority="1000" mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="html:head"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(*) le 2"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(*) le 2">
               <xsl:attribute name="id">HeadNodeCount</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The head element must not contain more than two elements.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="@*|node()" priority="-2" mode="M12">
      <xsl:apply-templates select="@*|*" mode="M12"/>
   </xsl:template>

   <!--PATTERN LinkAllowedAttributes-->


	<!--RULE -->
<xsl:template match="html:link" priority="1000" mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="html:link"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $a in @* satisfies (name($a) = tokenize('rel type href', '\s+'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $a in @* satisfies (name($a) = tokenize('rel type href', '\s+'))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Only attributes (<xsl:text/>
                  <xsl:value-of select="'rel type href'"/>
                  <xsl:text/>) are allowed in this context. Found: <xsl:text/>
                  <xsl:value-of select="for $a in @*[not(name() = tokenize('rel type href', '\s+'))] return concat( name($a), '=', $a)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M13"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M13"/>
   <xsl:template match="@*|node()" priority="-2" mode="M13">
      <xsl:apply-templates select="@*|*" mode="M13"/>
   </xsl:template>

   <!--PATTERN HeadAllowedAttributeValues-->


	<!--RULE -->
<xsl:template match="html:link" priority="1000" mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="html:link"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if (@rel) then matches(@rel, '^stylesheet', 'x') else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (@rel) then matches(@rel, '^stylesheet', 'x') else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Attribute @<xsl:text/>
                  <xsl:value-of select="'rel'"/>
                  <xsl:text/> of element <xsl:text/>
                  <xsl:value-of select="'html:link'"/>
                  <xsl:text/>: value must match /<xsl:text/>
                  <xsl:value-of select="'^stylesheet'"/>
                  <xsl:text/>/. Found: <xsl:text/>
                  <xsl:value-of select="@rel"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="@*|node()" priority="-2" mode="M14">
      <xsl:apply-templates select="@*|*" mode="M14"/>
   </xsl:template>

   <!--PATTERN BodyAllowedElements-->


	<!--RULE -->
<xsl:template match="html:body" priority="1000" mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="html:body"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $c in * satisfies (node-name($c) = (for $n in tokenize('table', '\s+') return QName($ns-uri, $n)))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $c in * satisfies (node-name($c) = (for $n in tokenize('table', '\s+') return QName($ns-uri, $n)))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Only elements (<xsl:text/>
                  <xsl:value-of select="'table'"/>
                  <xsl:text/>) are allowed in this context. Found: <xsl:text/>
                  <xsl:value-of select="distinct-values(*[not(string(node-name(.)) = tokenize('table', '\s+'))]/node-name(.))"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M15"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M15"/>
   <xsl:template match="@*|node()" priority="-2" mode="M15">
      <xsl:apply-templates select="@*|*" mode="M15"/>
   </xsl:template>

   <!--PATTERN TableAllowedElements-->


	<!--RULE -->
<xsl:template match="html:table" priority="1000" mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="html:table"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $c in * satisfies (node-name($c) = (for $n in tokenize('colgroup thead tfoot tbody', '\s+') return QName($ns-uri, $n)))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $c in * satisfies (node-name($c) = (for $n in tokenize('colgroup thead tfoot tbody', '\s+') return QName($ns-uri, $n)))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Only elements (<xsl:text/>
                  <xsl:value-of select="'colgroup thead tfoot tbody'"/>
                  <xsl:text/>) are allowed in this context. Found: <xsl:text/>
                  <xsl:value-of select="distinct-values(*[not(string(node-name(.)) = tokenize('colgroup thead tfoot tbody', '\s+'))]/node-name(.))"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M16"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M16"/>
   <xsl:template match="@*|node()" priority="-2" mode="M16">
      <xsl:apply-templates select="@*|*" mode="M16"/>
   </xsl:template>

   <!--PATTERN TableAllowedAttributes-->


	<!--RULE -->
<xsl:template match="html:table" priority="1000" mode="M17">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="html:table"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $a in @* satisfies (name($a) = tokenize('frame rules', '\s+'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $a in @* satisfies (name($a) = tokenize('frame rules', '\s+'))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Only attributes (<xsl:text/>
                  <xsl:value-of select="'frame rules'"/>
                  <xsl:text/>) are allowed in this context. Found: <xsl:text/>
                  <xsl:value-of select="for $a in @*[not(name() = tokenize('frame rules', '\s+'))] return concat( name($a), '=', $a)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M17"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M17"/>
   <xsl:template match="@*|node()" priority="-2" mode="M17">
      <xsl:apply-templates select="@*|*" mode="M17"/>
   </xsl:template>

   <!--PATTERN ColAllowedAttributes-->


	<!--RULE -->
<xsl:template match="html:col | html:colgroup" priority="1000" mode="M18">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="html:col | html:colgroup"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $a in @* satisfies (name($a) = tokenize('class align span width', '\s+'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $a in @* satisfies (name($a) = tokenize('class align span width', '\s+'))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Only attributes (<xsl:text/>
                  <xsl:value-of select="'class align span width'"/>
                  <xsl:text/>) are allowed in this context. Found: <xsl:text/>
                  <xsl:value-of select="for $a in @*[not(name() = tokenize('class align span width', '\s+'))] return concat( name($a), '=', $a)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M18"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M18"/>
   <xsl:template match="@*|node()" priority="-2" mode="M18">
      <xsl:apply-templates select="@*|*" mode="M18"/>
   </xsl:template>

   <!--PATTERN ColAllowedAttributeValues-->


	<!--RULE -->
<xsl:template match="html:col | html:colgroup" priority="1000" mode="M19">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="html:col | html:colgroup"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if (@class) then matches(@class, '^(rule-right|head)$', 'x') else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (@class) then matches(@class, '^(rule-right|head)$', 'x') else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Attribute @<xsl:text/>
                  <xsl:value-of select="'class'"/>
                  <xsl:text/> of element <xsl:text/>
                  <xsl:value-of select="'html:col | html:colgroup'"/>
                  <xsl:text/>: value must match /<xsl:text/>
                  <xsl:value-of select="'^(rule-right|head)$'"/>
                  <xsl:text/>/. Found: <xsl:text/>
                  <xsl:value-of select="@class"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M19"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M19"/>
   <xsl:template match="@*|node()" priority="-2" mode="M19">
      <xsl:apply-templates select="@*|*" mode="M19"/>
   </xsl:template>

   <!--PATTERN RowAllowedElements-->


	<!--RULE -->
<xsl:template match="html:tr" priority="1000" mode="M20">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="html:tr"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $c in * satisfies (node-name($c) = (for $n in tokenize('td', '\s+') return QName($ns-uri, $n)))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $c in * satisfies (node-name($c) = (for $n in tokenize('td', '\s+') return QName($ns-uri, $n)))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Only elements (<xsl:text/>
                  <xsl:value-of select="'td'"/>
                  <xsl:text/>) are allowed in this context. Found: <xsl:text/>
                  <xsl:value-of select="distinct-values(*[not(string(node-name(.)) = tokenize('td', '\s+'))]/node-name(.))"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M20"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M20"/>
   <xsl:template match="@*|node()" priority="-2" mode="M20">
      <xsl:apply-templates select="@*|*" mode="M20"/>
   </xsl:template>

   <!--PATTERN RowAllowedAttributeValues-->


	<!--RULE -->
<xsl:template match="tr" priority="1000" mode="M21">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="tr"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if (@class) then matches(@class, '^rule-below$', 'x') else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (@class) then matches(@class, '^rule-below$', 'x') else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Attribute @<xsl:text/>
                  <xsl:value-of select="'class'"/>
                  <xsl:text/> of element <xsl:text/>
                  <xsl:value-of select="'tr'"/>
                  <xsl:text/>: value must match /<xsl:text/>
                  <xsl:value-of select="'^rule-below$'"/>
                  <xsl:text/>/. Found: <xsl:text/>
                  <xsl:value-of select="@class"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M21"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M21"/>
   <xsl:template match="@*|node()" priority="-2" mode="M21">
      <xsl:apply-templates select="@*|*" mode="M21"/>
   </xsl:template>

   <!--PATTERN CellAllowedElements-->


	<!--RULE -->
<xsl:template match="html:td" priority="1000" mode="M22">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="html:td"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $c in * satisfies (node-name($c) = (for $n in tokenize('p ul ol', '\s+') return QName($ns-uri, $n)))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $c in * satisfies (node-name($c) = (for $n in tokenize('p ul ol', '\s+') return QName($ns-uri, $n)))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Only elements (<xsl:text/>
                  <xsl:value-of select="'p ul ol'"/>
                  <xsl:text/>) are allowed in this context. Found: <xsl:text/>
                  <xsl:value-of select="distinct-values(*[not(string(node-name(.)) = tokenize('p ul ol', '\s+'))]/node-name(.))"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M22"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M22"/>
   <xsl:template match="@*|node()" priority="-2" mode="M22">
      <xsl:apply-templates select="@*|*" mode="M22"/>
   </xsl:template>

   <!--PATTERN CellAllowedAttributes-->


	<!--RULE -->
<xsl:template match="html:td" priority="1000" mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="html:td"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $a in @* satisfies (name($a) = tokenize('class align colspan rowspan', '\s+'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $a in @* satisfies (name($a) = tokenize('class align colspan rowspan', '\s+'))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Only attributes (<xsl:text/>
                  <xsl:value-of select="'class align colspan rowspan'"/>
                  <xsl:text/>) are allowed in this context. Found: <xsl:text/>
                  <xsl:value-of select="for $a in @*[not(name() = tokenize('class align colspan rowspan', '\s+'))] return concat( name($a), '=', $a)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M23"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M23"/>
   <xsl:template match="@*|node()" priority="-2" mode="M23">
      <xsl:apply-templates select="@*|*" mode="M23"/>
   </xsl:template>

   <!--PATTERN CellAllowedAttributeValues-->


	<!--RULE -->
<xsl:template match="html:td" priority="1000" mode="M24">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="html:td"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if (@class) then matches(@class, '^rule-(right|below)$', 'x') else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (@class) then matches(@class, '^rule-(right|below)$', 'x') else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Attribute @<xsl:text/>
                  <xsl:value-of select="'class'"/>
                  <xsl:text/> of element <xsl:text/>
                  <xsl:value-of select="'html:td'"/>
                  <xsl:text/>: value must match /<xsl:text/>
                  <xsl:value-of select="'^rule-(right|below)$'"/>
                  <xsl:text/>/. Found: <xsl:text/>
                  <xsl:value-of select="@class"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M24"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M24"/>
   <xsl:template match="@*|node()" priority="-2" mode="M24">
      <xsl:apply-templates select="@*|*" mode="M24"/>
   </xsl:template>

   <!--PATTERN CellAllowedAttributeValueNotAlsoOnRowIf there is already class="rule-below" on tr, don't allow this on td-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">If there is already class="rule-below" on tr, don't allow this on td</svrl:text>

	  <!--RULE -->
<xsl:template match="tr[@class = 'rule-below']/td" priority="1000" mode="M25">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="tr[@class = 'rule-below']/td"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(@class = 'rule-below')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(@class = 'rule-below')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A table row with class="rule-below" must not contain a table cell with the same class attribute.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="@*|node()" priority="-2" mode="M25">
      <xsl:apply-templates select="@*|*" mode="M25"/>
   </xsl:template>

   <!--PATTERN OrderedListAllowedAttributes-->


	<!--RULE -->
<xsl:template match="html:ol" priority="1000" mode="M26">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="html:ol"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $a in @* satisfies (name($a) = tokenize('class', '\s+'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $a in @* satisfies (name($a) = tokenize('class', '\s+'))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Only attributes (<xsl:text/>
                  <xsl:value-of select="'class'"/>
                  <xsl:text/>) are allowed in this context. Found: <xsl:text/>
                  <xsl:value-of select="for $a in @*[not(name() = tokenize('class', '\s+'))] return concat( name($a), '=', $a)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M26"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M26"/>
   <xsl:template match="@*|node()" priority="-2" mode="M26">
      <xsl:apply-templates select="@*|*" mode="M26"/>
   </xsl:template>

   <!--PATTERN OrderedListAllowedAttributeValues-->


	<!--RULE -->
<xsl:template match="html:ol" priority="1000" mode="M27">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="html:ol"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if (@class) then matches(@class, '^(roman|alph|arabic)$', 'x') else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (@class) then matches(@class, '^(roman|alph|arabic)$', 'x') else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Attribute @<xsl:text/>
                  <xsl:value-of select="'class'"/>
                  <xsl:text/> of element <xsl:text/>
                  <xsl:value-of select="'html:ol'"/>
                  <xsl:text/>: value must match /<xsl:text/>
                  <xsl:value-of select="'^(roman|alph|arabic)$'"/>
                  <xsl:text/>/. Found: <xsl:text/>
                  <xsl:value-of select="@class"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M27"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M27"/>
   <xsl:template match="@*|node()" priority="-2" mode="M27">
      <xsl:apply-templates select="@*|*" mode="M27"/>
   </xsl:template>

   <!--PATTERN UnorderedListsPlainul may have no attributes-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">ul may have no attributes</svrl:text>

	  <!--RULE -->
<xsl:template match="html:ul" priority="1000" mode="M28">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="html:ul"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(@*)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(@*)">
               <xsl:attribute name="id">UnorderedListsNoAttributes</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>ul may not have an attribute</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M28"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M28"/>
   <xsl:template match="@*|node()" priority="-2" mode="M28">
      <xsl:apply-templates select="@*|*" mode="M28"/>
   </xsl:template>

   <!--PATTERN InlineMarkupAllowedElements-->


	<!--RULE -->
<xsl:template match="html:p|html:sub|html:sup|html:b|html:i" priority="1000" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="html:p|html:sub|html:sup|html:b|html:i"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $c in * satisfies (node-name($c) = (for $n in tokenize('b i img sub sup u', '\s+') return QName($ns-uri, $n)))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $c in * satisfies (node-name($c) = (for $n in tokenize('b i img sub sup u', '\s+') return QName($ns-uri, $n)))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Only elements (<xsl:text/>
                  <xsl:value-of select="'b i img sub sup u'"/>
                  <xsl:text/>) are allowed in this context. Found: <xsl:text/>
                  <xsl:value-of select="distinct-values(*[not(string(node-name(.)) = tokenize('b i img sub sup u', '\s+'))]/node-name(.))"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M29"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M29"/>
   <xsl:template match="@*|node()" priority="-2" mode="M29">
      <xsl:apply-templates select="@*|*" mode="M29"/>
   </xsl:template>

   <!--PATTERN InlineMarkupExclusions-->


	<!--RULE -->
<xsl:template match="html:sub|html:sup|html:b|html:i" priority="1000" mode="M30">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="html:sub|html:sup|html:b|html:i"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(.//*[node-name(.) = node-name(current())])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(.//*[node-name(.) = node-name(current())])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Element <xsl:text/>
                  <xsl:value-of select="'html:sub|html:sup|html:b|html:i'"/>
                  <xsl:text/> must not contain itself as descendant.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M30"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M30"/>
   <xsl:template match="@*|node()" priority="-2" mode="M30">
      <xsl:apply-templates select="@*|*" mode="M30"/>
   </xsl:template>

   <!--PATTERN MarkupThatShouldBeLaTeXText and images that look like equations-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Text and images that look like equations</svrl:text>

	  <!--RULE -->
<xsl:template match="html:p" priority="1002" mode="M31">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="html:p"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(matches(., '[=&lt;&gt;∀-∑∓-⋿]'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(matches(., '[=&lt;&gt;∀-∑∓-⋿]'))">
               <xsl:attribute name="id">TextNoEquations</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Please consider using LaTeX markup for equations (for proper spacing, etc.)</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M31"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="html:img[matches(@alt, '[$]')]" priority="1001" mode="M31">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="html:img[matches(@alt, '[$]')]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="starts-with(@src, 'ieq_')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="starts-with(@src, 'ieq_')">
               <xsl:attribute name="id">NoInlineEquationPrefix</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>If this is a LaTeX inline equation, please refer to a @src file whose name starts with 'ieq_'</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="ends-with(@src, '.png')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ends-with(@src, '.png')">
               <xsl:attribute name="id">NoInlineEquationPrefix</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>If this is a LaTeX inline equation, please refer to a PNG @src file whose name ends with '.png'</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M31"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="html:img[starts-with(@src, 'ieq_')]" priority="1000" mode="M31">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="html:img[starts-with(@src, 'ieq_')]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(matches(@alt, '^\s*$'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(matches(@alt, '^\s*$'))">
               <xsl:attribute name="id">EmptyLaTeX</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>LaTeX inline equation should not be empty</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M31"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M31"/>
   <xsl:template match="@*|node()" priority="-2" mode="M31">
      <xsl:apply-templates select="@*|*" mode="M31"/>
   </xsl:template>

   <!--PATTERN EquationImageAllowedAttributes-->


	<!--RULE -->
<xsl:template match="html:img[starts-with(@src, 'ieq_')]" priority="1000" mode="M32">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="html:img[starts-with(@src, 'ieq_')]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $a in @* satisfies (name($a) = tokenize('src alt', '\s+'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $a in @* satisfies (name($a) = tokenize('src alt', '\s+'))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Only attributes (<xsl:text/>
                  <xsl:value-of select="'src alt'"/>
                  <xsl:text/>) are allowed in this context. Found: <xsl:text/>
                  <xsl:value-of select="for $a in @*[not(name() = tokenize('src alt', '\s+'))] return concat( name($a), '=', $a)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M32"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M32"/>
   <xsl:template match="@*|node()" priority="-2" mode="M32">
      <xsl:apply-templates select="@*|*" mode="M32"/>
   </xsl:template>

   <!--PATTERN NonEquationImagesMustBePresentNon-equation images must be present-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Non-equation images must be present</svrl:text>

	  <!--RULE -->
<xsl:template match="html:img[not(starts-with(@src, 'ieq_'))]" priority="1000" mode="M33">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="html:img[not(starts-with(@src, 'ieq_'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="letex:file-exists(                            resolve-uri(                              @src,                               $base-uri                            )                          )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="letex:file-exists( resolve-uri( @src, $base-uri ) )">
               <xsl:attribute name="id">ImageMissing</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The non-equation image <xsl:text/>
                  <xsl:value-of select="@src"/>
                  <xsl:text/> must be present at its @src location.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*" mode="M33"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M33"/>
   <xsl:template match="@*|node()" priority="-2" mode="M33">
      <xsl:apply-templates select="@*|*" mode="M33"/>
   </xsl:template>
</xsl:stylesheet>