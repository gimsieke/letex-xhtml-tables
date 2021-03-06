<?xml version="1.0" encoding="utf-8"?>
<s:schema
  xmlns:s="http://purl.oclc.org/dsdl/schematron" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:java-file="java:java.io.File"
  xmlns:java-uri="java:java.net.URI"
  xmlns:letex="http://www.le-tex.de/namespace"
  queryBinding="xslt2"
  defaultPhase="#ALL">

   <s:ns prefix="html" uri="http://www.w3.org/1999/xhtml" />
   <s:ns prefix="letex" uri="http://www.le-tex.de/namespace" />

   <xsl:function name="letex:file-exists" as="xs:boolean">
      <xsl:param name="uri" as="xs:string?"/>
      <xsl:value-of select="java-file:exists(java-file:new(java-uri:new($uri)))"/>
   </xsl:function>


   <s:title>ISO Schematron rules for Dubbel Table Digitization content checking</s:title>

   <s:phase id="err">
      <s:active pattern="HTML" />
      <s:active pattern="HeadAllowedElements" />
      <s:active pattern="Head" />
      <s:active pattern="LinkAllowedAttributes" />
      <s:active pattern="StylesheetMustBePresent" />
      <s:active pattern="HeadAllowedAttributeValues" />
      <s:active pattern="BodyAllowedElements" />
      <s:active pattern="TableAllowedElements" />
      <s:active pattern="TableAllowedAttributes" />
      <s:active pattern="ColAllowedAttributes" />
      <s:active pattern="ColAllowedAttributeValues" />
      <s:active pattern="RowAllowedElements" />
      <s:active pattern="RowAllowedAttributeValues" />
      <s:active pattern="CellAllowedElements" />
      <s:active pattern="CellAllowedAttributes" />
      <s:active pattern="CellAllowedAttributeValues" />
      <s:active pattern="CellAllowedAttributeValueNotAlsoOnRow" />
      <s:active pattern="InlineMarkupAllowedElements" />
      <s:active pattern="InlineMarkupExclusions" />
      <s:active pattern="EquationImageAllowedAttributes" />
      <s:active pattern="NonEquationImagesMustBePresent" />
      <s:active pattern="OrderedListAllowedAttributes" />
      <s:active pattern="OrderedListAllowedAttributeValues" />
      <s:active pattern="UnorderedListsPlain" />
   </s:phase>

   <s:phase id="wrn">
      <s:active pattern="MarkupThatShouldBeLaTeX" />
   </s:phase>

   <s:let name="ns-uri" value="'http://www.w3.org/1999/xhtml'" />

   <s:let name="base-uri" value="document-uri(/)" />

   <s:p>Copyright (C) 2010, le-tex publishing services GmbH</s:p>

   <s:p>Version: 1.0.4 (2009-03-11)</s:p>

   <s:pattern id="AllowedElements" abstract="true">
      <s:rule context="$parent-name-pattern">
         <s:assert test="every $c in * satisfies (node-name($c) = (for $n in tokenize('$child-names', '\s+') return QName($ns-uri, $n)))">Only elements (<s:value-of select="'$child-names'"/>) are allowed in this context. Found: <s:value-of select="distinct-values(*[not(string(node-name(.)) = tokenize('$child-names', '\s+'))]/node-name(.))" /></s:assert>
      </s:rule>
   </s:pattern>

   <s:pattern id="NoImmediateText" abstract="true">
      <s:rule context="$parent-name-pattern">
         <s:assert test="every $t in text() satisfies matches($t, '^\s*$', 's')">Only elements but no immediate text nodes are allowed in this context. Found: <s:value-of select="string-join(text()[not(matches(., '^[\r\n\t ]*$'))], '|')" /></s:assert>
      </s:rule>
   </s:pattern>

   <s:pattern id="AllowedAttributes" abstract="true">
      <s:rule context="$element-name">
         <s:assert test="every $a in @* satisfies (name($a) = tokenize('$attribute-names', '\s+'))">Only attributes (<s:value-of select="'$attribute-names'"/>) are allowed in this context. Found: <s:value-of select="for $a in @*[not(name() = tokenize('$attribute-names', '\s+'))] return concat( name($a), '=', $a)" /></s:assert>
      </s:rule>
   </s:pattern>

   <s:pattern id="MandatoryAttributes" abstract="true">
      <s:rule context="$element-name">
         <s:assert test="every $m in tokenize('$attribute-names', '\s+') satisfies (some $a in @* satisfies (name($a) = $m))">Attributes (<s:value-of select="'$attribute-names'"/>) are mandatory in this context. Found: <s:value-of select="for $a in @* return name($a)" /></s:assert>
      </s:rule>
   </s:pattern>

   <s:pattern id="AllowedAttributeValues" abstract="true">
      <s:rule context="$element-name">
         <s:assert test="if (@$attribute-name) then (every $t in tokenize(@$attribute-name, '\s+') satisfies ($t = 'attention' or matches($t, '$attribute-value-regex', 'x'))) else true()">Attribute @<s:value-of select="'$attribute-name'"/> of element <s:value-of select="'$element-name'"/>: value must match /<s:value-of select="'$attribute-value-regex'"/>/ (or 'attention', which is always acceptable). Found: <s:value-of select="@$attribute-name" /></s:assert>
      </s:rule>
   </s:pattern>

   <s:pattern id="Exclusion" abstract="true">
      <s:rule context="$parent-name-pattern">
         <s:assert test="not(.//*[node-name(.) = node-name(current())])">Element <s:value-of select="'$parent-name-pattern'"/> must not contain itself as descendant.</s:assert>
      </s:rule>
   </s:pattern>


   <s:pattern id="HTML">
      <s:title>Document type</s:title>
      <s:rule context="/*">
         <s:assert test="node-name(.) = QName($ns-uri, 'html')" id="root">The root element must be 'html' in the namespace '<s:value-of select="$ns-uri"/>'. Found: '<s:value-of select="local-name(.)" />' in the namespace '<s:value-of select="namespace-uri-from-QName(node-name(.))" />'.</s:assert>
      </s:rule>
   </s:pattern>

   <s:pattern id="HeadAllowedElements" is-a="AllowedElements">
      <s:title>Element 'head' allowed child elements</s:title>
      <s:param name="parent-name-pattern" value="html:head" />
      <s:param name="child-names" value="title link" />
   </s:pattern>

   <s:pattern id="Head">
      <s:title>Meta info</s:title>
      <s:rule context="html:head">
         <s:assert test="count(*) le 2" id="HeadNodeCount">The head element must not contain more than two elements.</s:assert>
      </s:rule>
   </s:pattern>

   <s:pattern id="LinkAllowedAttributes" is-a="AllowedAttributes">
      <s:title>link may contain a rel, type and href attribute (and nothing else)</s:title>
      <s:param name="element-name" value="html:link" />
      <s:param name="attribute-names" value="rel type href" />
   </s:pattern>

   <s:pattern id="HeadAllowedAttributeValues" is-a="AllowedAttributeValues">
      <s:title>link rel attribute may only be 'stylesheet'</s:title>
      <s:param name="element-name" value="html:link" />
      <s:param name="attribute-name" value="rel" />
      <s:param name="attribute-value-regex" value="^stylesheet" />
   </s:pattern>

   <s:pattern id="StylesheetMustBePresent">
      <s:title>A referenced css stylesheet must be present.</s:title>
      <s:rule context="html:link[@rel='stylesheet']">
         <s:assert test="@type='text/css'" id="StylesheetPresentCSS">The type of a rel=stylesheet link must be text/css.</s:assert>
         <s:assert test="letex:file-exists(
                           resolve-uri(
                             @href, 
                             $base-uri
                           )
                         )" id="StylesheetMissing">The stylesheet <s:value-of select="@href"/> must be present at its @href location (for visual checking).</s:assert>
         <s:assert test="@type='text/css'" id="StylesheetPresentCSS">The type of a rel=stylesheet link must be text/css.</s:assert>
      </s:rule>
   </s:pattern>

   <s:pattern id="BodyAllowedElements" is-a="AllowedElements">
      <s:title>Element 'body' allowed child elements</s:title>
      <s:param name="parent-name-pattern" value="html:body" />
      <s:param name="child-names" value="table" />
   </s:pattern>

   <s:pattern id="TableAllowedElements" is-a="AllowedElements">
      <s:title>Element 'table' allowed child elements (everything except caption and immediate col or tr)</s:title>
      <s:param name="parent-name-pattern" value="html:table" />
      <s:param name="child-names" value="colgroup thead tfoot tbody" />
   </s:pattern>

   <s:pattern id="TableAllowedAttributes" is-a="AllowedAttributes">
      <s:title>Table may have a frame and rules attributes (and nothing else)</s:title>
      <s:param name="element-name" value="html:table" />
      <s:param name="attribute-names" value="frame rules" />
   </s:pattern>

   <s:pattern id="ColAllowedAttributes" is-a="AllowedAttributes">
      <s:title>Col or colgroup may have a class, an align, a span and a width attribute</s:title>
      <s:param name="element-name" value="html:col | html:colgroup" />
      <s:param name="attribute-names" value="class align span width" />
   </s:pattern>

   <s:pattern id="ColAllowedAttributeValues" is-a="AllowedAttributeValues">
      <s:title>col or colgroup class attribute may only be 'rule-right</s:title>
      <s:param name="element-name" value="html:col | html:colgroup" />
      <s:param name="attribute-name" value="class" />
      <s:param name="attribute-value-regex" value="^(rule-right|head)$" />
   </s:pattern>

   <s:pattern id="RowAllowedElements" is-a="AllowedElements">
      <s:title>Element 'tr' allowed child elements</s:title>
      <s:param name="parent-name-pattern" value="html:tr" />
      <s:param name="child-names" value="td" />
   </s:pattern>

   <s:pattern id="RowAllowedAttributeValues" is-a="AllowedAttributeValues">
      <s:title>tr class attribute may only be 'rule-below'</s:title>
      <s:param name="element-name" value="html:tr" />
      <s:param name="attribute-name" value="class" />
      <s:param name="attribute-value-regex" value="^rule-below$" />
   </s:pattern>

   <s:pattern id="CellAllowedElements" is-a="AllowedElements">
      <s:title>Element 'td' allowed child elements</s:title>
      <s:param name="parent-name-pattern" value="html:td" />
      <s:param name="child-names" value="p ul ol" />
   </s:pattern>

   <s:pattern id="CellNoImmediateText" is-a="NoImmediateText">
      <s:title>Element 'td' doesn't allow immediate text, only elements</s:title>
      <s:param name="parent-name-pattern" value="html:td" />
   </s:pattern>

   <s:pattern id="CellAllowedAttributes" is-a="AllowedAttributes">
      <s:title>Cell may have a class, align, colspan, and a rowspan attribute (and nothing else)</s:title>
      <s:param name="element-name" value="html:td" />
      <s:param name="attribute-names" value="class align colspan rowspan" />
   </s:pattern>

   <s:pattern id="CellAllowedAttributeValues" is-a="AllowedAttributeValues">
      <s:title>td class attribute may only be 'rule-right' or 'rule-below'</s:title>
      <s:param name="element-name" value="html:td" />
      <s:param name="attribute-name" value="class" />
      <s:param name="attribute-value-regex" value="^rule-(right|below)$" />
   </s:pattern>

   <s:pattern id="CellAllowedAttributeValueNotAlsoOnRow">
      <s:title>If there is already class="rule-below" on tr, don't allow this on td</s:title>
      <s:rule context="tr[@class = 'rule-below']/td">
         <s:assert test="not(@class = 'rule-below')">A table row with class="rule-below" must not contain a table cell with the same class attribute.</s:assert>
      </s:rule>
   </s:pattern>

   <s:pattern id="OrderedListAllowedAttributes" is-a="AllowedAttributes">
      <s:title>Ordered Lists may have a class attribute (and nothing else)</s:title>
      <s:param name="element-name" value="html:ol" />
      <s:param name="attribute-names" value="class" />
   </s:pattern>

   <s:pattern id="OrderedListAllowedAttributeValues" is-a="AllowedAttributeValues">
      <s:title>ol class attribute may only be 'roman', 'alph' or 'arabic'</s:title>
      <s:param name="element-name" value="html:ol" />
      <s:param name="attribute-name" value="class" />
      <s:param name="attribute-value-regex" value="^(roman|alph|arabic)$" />
   </s:pattern>

   <s:pattern id="UnorderedListsPlain">
      <s:title>ul may have no attributes</s:title>
      <s:rule context="html:ul">
         <s:assert test="not(@*)" id="UnorderedListsNoAttributes">ul may not have an attribute</s:assert>
      </s:rule>
   </s:pattern>

   <s:pattern id="InlineMarkupAllowedElements" is-a="AllowedElements">
      <s:title>Child elements that is permissible within standard inline markup</s:title>
      <s:param name="parent-name-pattern" value="html:p|html:sub|html:sup|html:b|html:i" />
      <s:param name="child-names" value="b i img sub sup u" />
   </s:pattern>

   <s:pattern id="InlineMarkupExclusions" is-a="Exclusion">
      <s:title>Elements that must not contain itself as descendant.</s:title>
      <s:param name="parent-name-pattern" value="html:sub|html:sup|html:b|html:i" />
   </s:pattern>

   <s:pattern id="MarkupThatShouldBeLaTeX">
      <s:title>Text and images that look like equations</s:title>
      <s:rule context="html:p">
         <s:assert test="not(matches(., '[=&lt;&gt;&#x2200;-&#x2211;&#x2213;-&#x22ff;]'))" id="TextNoEquations">Please consider using LaTeX markup for equations (for proper spacing, etc.)</s:assert>
      </s:rule>
      <s:rule context="html:img[matches(@alt, '[$]')]">
         <s:assert test="starts-with(@src, 'ieq_')" id="NoInlineEquationPrefix">If this is a LaTeX inline equation, please refer to a @src file whose name starts with 'ieq_'</s:assert>
         <s:assert test="ends-with(@src, '.png')" id="NoInlineEquationPrefix">If this is a LaTeX inline equation, please refer to a PNG @src file whose name ends with '.png'</s:assert>
      </s:rule>
      <s:rule context="html:img[starts-with(@src, 'ieq_')]">
         <s:assert test="not(matches(@alt, '^\s*$'))" id="EmptyLaTeX">LaTeX inline equation should not be empty</s:assert>
      </s:rule>
   </s:pattern>

   <s:pattern id="EquationImageAllowedAttributes" is-a="AllowedAttributes">
      <s:title>Equation images may have a src and an alt attribute (and nothing else)</s:title>
      <s:param name="element-name" value="html:img[starts-with(@src, 'ieq_')]" />
      <s:param name="attribute-names" value="src alt class" />
   </s:pattern>

   <s:pattern id="EquationImageAllowedAttributeValues" is-a="AllowedAttributeValues">
      <s:title>img class attribute may only be 'attention'</s:title>
      <s:param name="element-name" value="html:img" />
      <s:param name="attribute-name" value="class" />
      <s:param name="attribute-value-regex" value="^$" /><!-- attention is always permissible -->
   </s:pattern>

   <s:pattern id="NonEquationImagesMustBePresent">
      <s:title>Non-equation images must be present</s:title>
      <s:rule context="html:img[not(starts-with(@src, 'ieq_'))]">
         <s:assert test="letex:file-exists(
                           resolve-uri(
                             @src, 
                             $base-uri
                           )
                         )" id="ImageMissing">The non-equation image <s:value-of select="@src"/> must be present at its @src location.</s:assert>
      </s:rule>
   </s:pattern>

</s:schema>