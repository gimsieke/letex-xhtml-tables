<?xml version="1.0" encoding="utf-8"?>
<s:schema
  xmlns:s="http://purl.oclc.org/dsdl/schematron" 
  queryBinding="xslt2">

   <s:title>ISO Schematron rules for Dubbel Table Digitization content checking</s:title>

   <s:ns prefix="html" uri="http://www.w3.org/1999/xhtml" />

   <s:p>Copyright (C) 2010, le-tex publishing services GmbH</s:p>

   <s:p>Version: $Id: din-dbk.sch 5584 2009-11-24 12:14:07Z gerrit $</s:p>

   <s:pattern id="AllowedElements" abstract="true">
      <s:rule context="$parent-name">
         <s:assert test="every $c in * satisfies (string(node-name($c)) = tokenize('$child-names', '\s+'))">Only elements (<s:value-of select="'$child-names'"/>) are allowed in this context. Found: <s:value-of select="distinct-values(*[not(string(node-name(.)) = tokenize('$child-names', '\s+'))]/node-name(.))" /></s:assert>
      </s:rule>
   </s:pattern>

   <s:pattern id="AllowedAttributes" abstract="true">
      <s:rule context="$element-name">
         <s:assert test="every $a in @* satisfies (name($a) = tokenize('$attribute-names', '\s+'))">Only attributes (<s:value-of select="'$attribute-names'"/>) are allowed in this context. Found: <s:value-of select="@*[not(name() = tokenize('$attribute-nam
  s:assert>
      </s:rule>
   </s:pattern>

   <s:pattern id="MandatoryAttributes" abstract="true">
      <s:rule context="$element-name">
         <s:assert test="every $m in tokenize('$attribute-names', '\s+') satisfies (some $a in @* satisfies (name($a) = $m))">Attributes (<s:value-of select="'$attribute-names'"/>) are mandatory in this context. Found: <s:value-of select="for $a in @* return name($a)" /></s:assert>
      </s:rule>
   </s:pattern>

   <s:pattern id="AllowedAttributeValues" abstract="true">
      <s:rule context="$element-name">
         <s:assert test="if (@$attribute-name) then matches(@$attribute-name, '$attribute-value-regex', 'x') else true()">Attribute @<s:value-of select="'$attribute-name'"/> of element <s:value-of select="'$element-name'"/>: value must match /<s:value-of select="'$attribute-value-regex'"/>/. Found: <s:value-of select="@$attribute-name" /></s:assert>
      </s:rule>
   </s:pattern>

   <s:pattern id="Exclusion" abstract="true">
      <s:rule context="$parent-name">
         <s:assert test="not(.//*[name() = $parent-name])">Element <s:value-of select="'$parent-name'"/> must not contain itself as descendant.</s:assert>
      </s:rule>
   </s:pattern>


   <s:pattern id="HTML">
      <s:title>Document type</s:title>
      <s:rule context="/*">
         <s:assert test="self::html:html" id="root">The root element must be 'html' in the namespace 'http://www.w3.org/1999/xhtml'. Found: '<s:value-of select="name()" />'.</s:assert>
      </s:rule>
   </s:pattern>

   <s:pattern id="HeadAllowedElements" is-a="AllowedElements">
      <s:title>Element 'head' allowed child elements</s:title>
      <s:param name="parent-name" value="html:body" />
      <s:param name="child-names" value="title link" />
   </s:pattern>

   <s:pattern id="LinkAllowedAttributes" is-a="AllowedAttributes">
      <s:title>link may contain a rel attribute (and nothing else)</s:title>
      <s:param name="element-name" value="html:link" />
      <s:param name="attribute-names" value="rel" />
   </s:pattern>

   <s:pattern id="HeadAllowedAttributeValues" is-a="AllowedAttributeValues">
      <s:title>link rel attribute may only be 'stylesheet'</s:title>
      <s:param name="element-name" value="html:link" />
      <s:param name="attribute-name" value="rel" />
      <s:param name="attribute-value-regex" value="^stylesheet" />
   </s:pattern>

   <s:pattern id="BodyAllowedElements" is-a="AllowedElements">
      <s:title>Element 'body' allowed child elements</s:title>
      <s:param name="parent-name" value="html:body" />
      <s:param name="child-names" value="table" />
   </s:pattern>

   <s:pattern id="TableAllowedElements" is-a="AllowedElements">
      <s:title>Element 'table' allowed child elements (everything except caption and immediate col or tr)</s:title>
      <s:param name="parent-name" value="html:table" />
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
      <s:param name="attribute-value-regex" value="^rule-right$" />
   </s:pattern>

   <s:pattern id="CellAllowedAttributeValues" is-a="AllowedAttributeValues">
      <s:title>td class attribute may only be 'rule-right' or 'rule-below'</s:title>
      <s:param name="element-name" value="html:td" />
      <s:param name="attribute-name" value="class" />
      <s:param name="attribute-value-regex" value="^rule-(right|below)$" />
   </s:pattern>

   <s:pattern id="RowAllowedElements" is-a="AllowedElements">
      <s:title>Element 'tr' allowed child elements</s:title>
      <s:param name="parent-name" value="html:tr" />
      <s:param name="child-names" value="td" />
   </s:pattern>

   <s:pattern id="CellAllowedElements" is-a="AllowedElements">
      <s:title>Element 'td' allowed child elements</s:title>
      <s:param name="parent-name" value="html:td" />
      <s:param name="child-names" value="p" />
   </s:pattern>

   <s:pattern id="CellAllowedAttributes" is-a="AllowedAttributes">
      <s:title>Cell may have a class, align, colspan, and a rowspan attribute (and nothing else)</s:title>
      <s:param name="element-name" value="html:td" />
      <s:param name="attribute-names" value="class align colspan rowspan" />
   </s:pattern>

   <s:pattern id="InlineMarkupAllowedElements" is-a="AllowedElements">
      <s:title>Child elements that is permissible within standard inline markup</s:title>
      <s:param name="parent-name" value="html:p|html:sub|html:sup|html:b|html:i|html:u" />
      <s:param name="child-names" value="b i img sub sup u" />
   </s:pattern>

   <s:pattern id="InlineMarkupExclusions" is-a="Exclusion">
      <s:title>Elements that must not contain itself as descendant.</s:title>
      <s:param name="parent-name" value="html:sub|html:sup|html:b|html:i" />
   </s:pattern>

   <s:pattern id="EmphasisMandatoryAttributes" is-a="MandatoryAttributes">
      <s:title>Emphasis must have a role attribute</s:title>
      <s:param name="element-name" value="emphasis" />
      <s:param name="attribute-names" value="role" />
   </s:pattern>

   <s:pattern id="RowAllowedAttributeValues" is-a="AllowedAttributeValues">
      <s:title>tr class attribute may only be 'rule-below'</s:title>
      <s:param name="element-name" value="tr" />
      <s:param name="attribute-name" value="class" />
      <s:param name="attribute-value-regex" value="^rule-below$" />
   </s:pattern>


</s:schema>