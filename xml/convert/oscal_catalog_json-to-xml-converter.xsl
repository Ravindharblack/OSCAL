<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:m="http://csrc.nist.gov/ns/oscal/1.0/md-convertor"
                version="3.0"
                xpath-default-namespace="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="#all">
   <xsl:output indent="yes" method="xml"/>
   <!-- OSCAL catalog conversion stylesheet supports JSON->XML conversion -->
   <xsl:param name="target-ns"
              as="xs:string?"
              select="'http://csrc.nist.gov/ns/oscal/1.0'"/>
   <!-- 00000000000000000000000000000000000000000000000000000000000000 -->
   <xsl:output indent="yes"/>
   <xsl:strip-space elements="*"/>
   <xsl:preserve-space elements="string"/>
   <xsl:param name="json-file" as="xs:string?"/>
   <xsl:variable name="json-xml" select="unparsed-text($json-file) ! json-to-xml(.)"/>
   <xsl:template name="xsl:initial-template" match="/">
      <xsl:choose>
         <xsl:when test="matches($json-file,'\S') and exists($json-xml/map)">
            <xsl:apply-templates select="$json-xml" mode="json2xml"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates mode="json2xml"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="/map[empty(@key)]" priority="10" mode="json2xml">
      <xsl:apply-templates mode="#current" select="*[@key=('catalog')]"/>
   </xsl:template>
   <xsl:template match="array" priority="10" mode="json2xml">
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template match="array[@key='prose']" priority="11" mode="json2xml">
      <xsl:variable name="text-contents" select="string-join(string,'&#xA;')"/>
      <xsl:call-template name="parse">
         <xsl:with-param name="markdown-str" select="$text-contents"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="string[@key='prose']" priority="11" mode="json2xml">
      <xsl:call-template name="parse">
         <xsl:with-param name="markdown-str" select="string(.)"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="string[@key='RICHTEXT']" mode="json2xml">
      <xsl:call-template name="parse">
         <xsl:with-param name="markdown-str" select="string(.)"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="string[@key='STRVALUE']" mode="json2xml">
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template mode="as-attribute" match="*"/>
   <xsl:template mode="as-attribute" match="string[@key='id']" priority="0.4">
      <xsl:attribute name="id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 00000000000000000000000000000000000000000000000000000000000000 -->
   <!-- 000 Handling assembly "metadata" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='metadata']" priority="4" mode="json2xml">
      <xsl:element name="metadata" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('last-modified-date')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('version')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('oscal-version')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('doc-id', 'document-ids')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('role', 'roles')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('party', 'parties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('notes')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "back-matter" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='back-matter']" priority="4" mode="json2xml">
      <xsl:element name="back-matter" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('citation', 'citations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('resource', 'resources')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "link" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--metadata control controls subcontrol subcontrols param parameters part parts-->
   <!--*[@key='metadata']/*[@key='link'] | *[@key='links'] | array[@key='links']/* | *[@key='control']/*[@key='link'] | *[@key='links'] | array[@key='links']/* | *[@key='subcontrol']/*[@key='link'] | *[@key='links'] | array[@key='links']/* | *[@key='param']/*[@key='link'] | *[@key='links'] | array[@key='links']/* | *[@key='part']/*[@key='link'] | *[@key='links'] | array[@key='links']/* | *[@key='controls']/*[@key='link'] | *[@key='links'] | array[@key='links']/* | *[@key='controls']/*/*[@key='link'] | *[@key='links'] | array[@key='links']/*  | *[@key='subcontrols']/*[@key='link'] | *[@key='links'] | array[@key='links']/* | *[@key='subcontrols']/*/*[@key='link'] | *[@key='links'] | array[@key='links']/*  | *[@key='parameters']/*[@key='link'] | *[@key='links'] | array[@key='links']/* | *[@key='parameters']/*/*[@key='link'] | *[@key='links'] | array[@key='links']/*  | *[@key='parts']/*[@key='link'] | *[@key='links'] | array[@key='links']/* | *[@key='parts']/*/*[@key='link'] | *[@key='links'] | array[@key='links']/* -->
   <!--*[@key='link'] | *[@key='links'] | array[@key='links']/*-->
   <xsl:template match="*[@key='metadata']/*[@key='link'] | *[@key='links'] | array[@key='links']/* | *[@key='control']/*[@key='link'] | *[@key='links'] | array[@key='links']/* | *[@key='subcontrol']/*[@key='link'] | *[@key='links'] | array[@key='links']/* | *[@key='param']/*[@key='link'] | *[@key='links'] | array[@key='links']/* | *[@key='part']/*[@key='link'] | *[@key='links'] | array[@key='links']/* | *[@key='controls']/*[@key='link'] | *[@key='links'] | array[@key='links']/* | *[@key='controls']/*/*[@key='link'] | *[@key='links'] | array[@key='links']/*  | *[@key='subcontrols']/*[@key='link'] | *[@key='links'] | array[@key='links']/* | *[@key='subcontrols']/*/*[@key='link'] | *[@key='links'] | array[@key='links']/*  | *[@key='parameters']/*[@key='link'] | *[@key='links'] | array[@key='links']/* | *[@key='parameters']/*/*[@key='link'] | *[@key='links'] | array[@key='links']/*  | *[@key='parts']/*[@key='link'] | *[@key='links'] | array[@key='links']/* | *[@key='parts']/*/*[@key='link'] | *[@key='links'] | array[@key='links']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="link" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:for-each select="string[@key='text'], self::string">
            <xsl:variable name="markup">
               <xsl:apply-templates mode="infer-inlines"/>
            </xsl:variable>
            <xsl:apply-templates mode="cast-ns" select="$markup"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='links'][array/@key='text'] |  array[@key='links']/map[array/@key='text']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="links">
            <xsl:apply-templates mode="expand" select="array[@key='text']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='links']/array[@key='text']/string |  array[@key='links']/map/array[@key='text']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key='text']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="text">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- 000 Handling field "last-modified-date" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--metadata-->
   <!--*[@key='metadata']/*[@key='last-modified-date']-->
   <!--*[@key='last-modified-date']-->
   <xsl:template match="*[@key='metadata']/*[@key='last-modified-date']"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="last-modified-date" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "version" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--metadata-->
   <!--*[@key='metadata']/*[@key='version']-->
   <!--*[@key='version']-->
   <xsl:template match="*[@key='metadata']/*[@key='version']"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="version" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "oscal-version" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--metadata-->
   <!--*[@key='metadata']/*[@key='oscal-version']-->
   <!--*[@key='oscal-version']-->
   <xsl:template match="*[@key='metadata']/*[@key='oscal-version']"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="oscal-version" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "doc-id" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--metadata citation citations-->
   <!--*[@key='metadata']/*[@key='doc-id'] | *[@key='document-ids'] | array[@key='document-ids']/* | *[@key='citation']/*[@key='doc-id'] | *[@key='document-ids'] | array[@key='document-ids']/* | *[@key='citations']/*[@key='doc-id'] | *[@key='document-ids'] | array[@key='document-ids']/* | *[@key='citations']/*/*[@key='doc-id'] | *[@key='document-ids'] | array[@key='document-ids']/* -->
   <!--*[@key='doc-id'] | *[@key='document-ids'] | array[@key='document-ids']/*-->
   <xsl:template match="*[@key='metadata']/*[@key='doc-id'] | *[@key='document-ids'] | array[@key='document-ids']/* | *[@key='citation']/*[@key='doc-id'] | *[@key='document-ids'] | array[@key='document-ids']/* | *[@key='citations']/*[@key='doc-id'] | *[@key='document-ids'] | array[@key='document-ids']/* | *[@key='citations']/*/*[@key='doc-id'] | *[@key='document-ids'] | array[@key='document-ids']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="doc-id" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='document-ids'][array/@key='STRVALUE'] |  array[@key='document-ids']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="document-ids">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='document-ids']/array[@key='STRVALUE']/string |  array[@key='document-ids']/map/array[@key='STRVALUE']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key='STRVALUE']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="STRVALUE">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- 000 Handling flag "type" 000 -->
   <xsl:template match="*[@key='type']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='doc-id']/*[@key='type'] | *[@key='document-ids']/*[@key='type'] | array[@key='document-ids']/*/*[@key='type'] | *[@key='person-id']/*[@key='type'] | *[@key='person-ids']/*[@key='type'] | array[@key='person-ids']/*/*[@key='type'] | *[@key='org-id']/*[@key='type'] | *[@key='organization-ids']/*[@key='type'] | array[@key='organization-ids']/*/*[@key='type'] | *[@key='address']/*[@key='type'] | *[@key='addresses']/*[@key='type'] | array[@key='addresses']/*/*[@key='type'] | *[@key='phone']/*[@key='type'] | *[@key='telephone-numbers']/*[@key='type'] | array[@key='telephone-numbers']/*/*[@key='type'] | *[@key='notes']/*[@key='type']"
                 mode="as-attribute">
      <xsl:attribute name="type">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling field "prop" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--metadata group groups control controls subcontrol subcontrols part parts-->
   <!--*[@key='metadata']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='group']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='control']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='subcontrol']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='part']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='groups']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='groups']/*/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/*  | *[@key='controls']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='controls']/*/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/*  | *[@key='subcontrols']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='subcontrols']/*/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/*  | *[@key='parts']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='parts']/*/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* -->
   <!--*[@key='prop'] | *[@key='properties'] | array[@key='properties']/*-->
   <xsl:template match="*[@key='metadata']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='group']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='control']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='subcontrol']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='part']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='groups']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='groups']/*/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/*  | *[@key='controls']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='controls']/*/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/*  | *[@key='subcontrols']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='subcontrols']/*/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/*  | *[@key='parts']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='parts']/*/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="prop" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[not(@key=('id','ns','class'))]" mode="json2xml"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="(*[@key='prop'] | *[@key='properties'] | array[@key='properties']/*)/string[not(@key=('id','ns','class','STRVALUE','RICHTEXT'))]"
                 mode="as-attribute">
      <xsl:attribute name="name">
         <xsl:value-of select="@key"/>
      </xsl:attribute>
   </xsl:template>
   <xsl:template match="map[@key='properties'][array/@key=''] |  array[@key='properties']/map[array/@key='']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="properties">
            <xsl:apply-templates mode="expand" select="array[@key='']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='properties']/array[@key='']/string |  array[@key='properties']/map/array[@key='']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key='']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- 000 Handling flag "name" 000 -->
   <xsl:template match="*[@key='name']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='prop']/*[@key='name'] | *[@key='properties']/*[@key='name'] | array[@key='properties']/*/*[@key='name'] | *[@key='part']/*[@key='name'] | *[@key='parts']/*[@key='name'] | array[@key='parts']/*/*[@key='name']"
                 mode="as-attribute">
      <xsl:attribute name="name">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "ns" 000 -->
   <xsl:template match="*[@key='ns']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='prop']/*[@key='ns'] | *[@key='properties']/*[@key='ns'] | array[@key='properties']/*/*[@key='ns'] | *[@key='part']/*[@key='ns'] | *[@key='parts']/*[@key='ns'] | array[@key='parts']/*/*[@key='ns']"
                 mode="as-attribute">
      <xsl:attribute name="ns">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "class" 000 -->
   <xsl:template match="*[@key='class']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='prop']/*[@key='class'] | *[@key='properties']/*[@key='class'] | array[@key='properties']/*/*[@key='class'] | *[@key='group']/*[@key='class'] | *[@key='groups']/*[@key='class'] | array[@key='groups']/*/*[@key='class'] | *[@key='control']/*[@key='class'] | *[@key='controls']/*[@key='class'] | array[@key='controls']/*/*[@key='class'] | *[@key='subcontrol']/*[@key='class'] | *[@key='subcontrols']/*[@key='class'] | array[@key='subcontrols']/*/*[@key='class'] | *[@key='param']/*[@key='class'] | *[@key='parameters']/*[@key='class'] | array[@key='parameters']/*/*[@key='class'] | *[@key='part']/*[@key='class'] | *[@key='parts']/*[@key='class'] | array[@key='parts']/*/*[@key='class']"
                 mode="as-attribute">
      <xsl:attribute name="class">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling assembly "party" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='party'] | *[@key='parties']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="party" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('person', 'persons')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('org')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('notes')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='parties']/*" priority="3" mode="json2xml">
      <xsl:element name="party" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('person', 'persons')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('org')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('notes')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "person" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='person'] | *[@key='persons']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="person" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('person-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('short-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('org-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('person-id', 'person-ids')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('org-id', 'organization-ids')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('address', 'addresses')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('email', 'email-addresses')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('phone', 'telephone-numbers')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('url', 'URLs')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('notes')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='persons']/*" priority="3" mode="json2xml">
      <xsl:element name="person" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('person-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('short-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('org-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('person-id', 'person-ids')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('org-id', 'organization-ids')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('address', 'addresses')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('email', 'email-addresses')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('phone', 'telephone-numbers')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('url', 'URLs')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('notes')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "org" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='org']" priority="4" mode="json2xml">
      <xsl:element name="org" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('org-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('short-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('org-id', 'organization-ids')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('address', 'addresses')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('email', 'email-addresses')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('phone', 'telephone-numbers')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('url', 'URLs')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('notes')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "person-id" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--person persons-->
   <!--*[@key='person']/*[@key='person-id'] | *[@key='person-ids'] | array[@key='person-ids']/* | *[@key='persons']/*[@key='person-id'] | *[@key='person-ids'] | array[@key='person-ids']/* | *[@key='persons']/*/*[@key='person-id'] | *[@key='person-ids'] | array[@key='person-ids']/* -->
   <!--*[@key='person-id'] | *[@key='person-ids'] | array[@key='person-ids']/*-->
   <xsl:template match="*[@key='person']/*[@key='person-id'] | *[@key='person-ids'] | array[@key='person-ids']/* | *[@key='persons']/*[@key='person-id'] | *[@key='person-ids'] | array[@key='person-ids']/* | *[@key='persons']/*/*[@key='person-id'] | *[@key='person-ids'] | array[@key='person-ids']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="person-id" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='person-ids'][array/@key='STRVALUE'] |  array[@key='person-ids']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="person-ids">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='person-ids']/array[@key='STRVALUE']/string |  array[@key='person-ids']/map/array[@key='STRVALUE']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key='STRVALUE']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="STRVALUE">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- 000 Handling field "org-id" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--person persons org-->
   <!--*[@key='person']/*[@key='org-id'] | *[@key='organization-ids'] | array[@key='organization-ids']/* | *[@key='org']/*[@key='org-id'] | *[@key='organization-ids'] | array[@key='organization-ids']/* | *[@key='persons']/*[@key='org-id'] | *[@key='organization-ids'] | array[@key='organization-ids']/* | *[@key='persons']/*/*[@key='org-id'] | *[@key='organization-ids'] | array[@key='organization-ids']/* -->
   <!--*[@key='org-id'] | *[@key='organization-ids'] | array[@key='organization-ids']/*-->
   <xsl:template match="*[@key='person']/*[@key='org-id'] | *[@key='organization-ids'] | array[@key='organization-ids']/* | *[@key='org']/*[@key='org-id'] | *[@key='organization-ids'] | array[@key='organization-ids']/* | *[@key='persons']/*[@key='org-id'] | *[@key='organization-ids'] | array[@key='organization-ids']/* | *[@key='persons']/*/*[@key='org-id'] | *[@key='organization-ids'] | array[@key='organization-ids']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="org-id" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='organization-ids'][array/@key='STRVALUE'] |  array[@key='organization-ids']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="organization-ids">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='organization-ids']/array[@key='STRVALUE']/string |  array[@key='organization-ids']/map/array[@key='STRVALUE']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key='STRVALUE']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="STRVALUE">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- 000 Handling assembly "rlink" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='rlink'] | *[@key='rlinks']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="rlink" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('hash', 'hashes')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='rlinks']/*" priority="3" mode="json2xml">
      <xsl:element name="rlink" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('hash', 'hashes')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling flag "rel" 000 -->
   <xsl:template match="*[@key='rel']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='link']/*[@key='rel'] | *[@key='links']/*[@key='rel'] | array[@key='links']/*/*[@key='rel']"
                 mode="as-attribute">
      <xsl:attribute name="rel">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "media-type" 000 -->
   <xsl:template match="*[@key='media-type']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='link']/*[@key='media-type'] | *[@key='links']/*[@key='media-type'] | array[@key='links']/*/*[@key='media-type'] | *[@key='rlink']/*[@key='media-type'] | *[@key='rlinks']/*[@key='media-type'] | array[@key='rlinks']/*/*[@key='media-type'] | *[@key='base64']/*[@key='media-type']"
                 mode="as-attribute">
      <xsl:attribute name="media-type">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling field "person-name" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--person persons-->
   <!--*[@key='person']/*[@key='person-name'] | *[@key='persons']/*[@key='person-name'] | *[@key='persons']/*/*[@key='person-name'] -->
   <!--*[@key='person-name']-->
   <xsl:template match="*[@key='person']/*[@key='person-name'] | *[@key='persons']/*[@key='person-name'] | *[@key='persons']/*/*[@key='person-name'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="person-name" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "org-name" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--person persons org-->
   <!--*[@key='person']/*[@key='org-name'] | *[@key='org']/*[@key='org-name'] | *[@key='persons']/*[@key='org-name'] | *[@key='persons']/*/*[@key='org-name'] -->
   <!--*[@key='org-name']-->
   <xsl:template match="*[@key='person']/*[@key='org-name'] | *[@key='org']/*[@key='org-name'] | *[@key='persons']/*[@key='org-name'] | *[@key='persons']/*/*[@key='org-name'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="org-name" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "short-name" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--person persons org role roles-->
   <!--*[@key='person']/*[@key='short-name'] | *[@key='org']/*[@key='short-name'] | *[@key='role']/*[@key='short-name'] | *[@key='persons']/*[@key='short-name'] | *[@key='persons']/*/*[@key='short-name']  | *[@key='roles']/*[@key='short-name'] | *[@key='roles']/*/*[@key='short-name'] -->
   <!--*[@key='short-name']-->
   <xsl:template match="*[@key='person']/*[@key='short-name'] | *[@key='org']/*[@key='short-name'] | *[@key='role']/*[@key='short-name'] | *[@key='persons']/*[@key='short-name'] | *[@key='persons']/*/*[@key='short-name']  | *[@key='roles']/*[@key='short-name'] | *[@key='roles']/*/*[@key='short-name'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="short-name" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "address" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='address'] | *[@key='addresses']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="address" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('addr-line', 'postal-address')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('city')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('state')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('postal-code')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('country')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='addresses']/*" priority="3" mode="json2xml">
      <xsl:element name="address" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('addr-line', 'postal-address')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('city')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('state')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('postal-code')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('country')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "addr-line" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--address addresses-->
   <!--*[@key='address']/*[@key='addr-line'] | *[@key='postal-address'] | array[@key='postal-address']/* | *[@key='addresses']/*[@key='addr-line'] | *[@key='postal-address'] | array[@key='postal-address']/* | *[@key='addresses']/*/*[@key='addr-line'] | *[@key='postal-address'] | array[@key='postal-address']/* -->
   <!--*[@key='addr-line'] | *[@key='postal-address'] | array[@key='postal-address']/*-->
   <xsl:template match="*[@key='address']/*[@key='addr-line'] | *[@key='postal-address'] | array[@key='postal-address']/* | *[@key='addresses']/*[@key='addr-line'] | *[@key='postal-address'] | array[@key='postal-address']/* | *[@key='addresses']/*/*[@key='addr-line'] | *[@key='postal-address'] | array[@key='postal-address']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="addr-line" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='postal-address'][array/@key='STRVALUE'] |  array[@key='postal-address']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="postal-address">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='postal-address']/array[@key='STRVALUE']/string |  array[@key='postal-address']/map/array[@key='STRVALUE']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key='STRVALUE']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="STRVALUE">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- 000 Handling field "city" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--address addresses-->
   <!--*[@key='address']/*[@key='city'] | *[@key='addresses']/*[@key='city'] | *[@key='addresses']/*/*[@key='city'] -->
   <!--*[@key='city']-->
   <xsl:template match="*[@key='address']/*[@key='city'] | *[@key='addresses']/*[@key='city'] | *[@key='addresses']/*/*[@key='city'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="city" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "state" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--address addresses-->
   <!--*[@key='address']/*[@key='state'] | *[@key='addresses']/*[@key='state'] | *[@key='addresses']/*/*[@key='state'] -->
   <!--*[@key='state']-->
   <xsl:template match="*[@key='address']/*[@key='state'] | *[@key='addresses']/*[@key='state'] | *[@key='addresses']/*/*[@key='state'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="state" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "postal-code" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--address addresses-->
   <!--*[@key='address']/*[@key='postal-code'] | *[@key='addresses']/*[@key='postal-code'] | *[@key='addresses']/*/*[@key='postal-code'] -->
   <!--*[@key='postal-code']-->
   <xsl:template match="*[@key='address']/*[@key='postal-code'] | *[@key='addresses']/*[@key='postal-code'] | *[@key='addresses']/*/*[@key='postal-code'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="postal-code" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "country" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--address addresses-->
   <!--*[@key='address']/*[@key='country'] | *[@key='addresses']/*[@key='country'] | *[@key='addresses']/*/*[@key='country'] -->
   <!--*[@key='country']-->
   <xsl:template match="*[@key='address']/*[@key='country'] | *[@key='addresses']/*[@key='country'] | *[@key='addresses']/*/*[@key='country'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="country" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "email" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--person persons org-->
   <!--*[@key='person']/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/* | *[@key='org']/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/* | *[@key='persons']/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/* | *[@key='persons']/*/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/* -->
   <!--*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/*-->
   <xsl:template match="*[@key='person']/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/* | *[@key='org']/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/* | *[@key='persons']/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/* | *[@key='persons']/*/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="email" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='email-addresses'][array/@key='STRVALUE'] |  array[@key='email-addresses']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="email-addresses">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='email-addresses']/array[@key='STRVALUE']/string |  array[@key='email-addresses']/map/array[@key='STRVALUE']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key='STRVALUE']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="STRVALUE">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- 000 Handling field "phone" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--person persons org-->
   <!--*[@key='person']/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/* | *[@key='org']/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/* | *[@key='persons']/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/* | *[@key='persons']/*/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/* -->
   <!--*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/*-->
   <xsl:template match="*[@key='person']/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/* | *[@key='org']/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/* | *[@key='persons']/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/* | *[@key='persons']/*/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="phone" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='telephone-numbers'][array/@key='STRVALUE'] |  array[@key='telephone-numbers']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="telephone-numbers">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='telephone-numbers']/array[@key='STRVALUE']/string |  array[@key='telephone-numbers']/map/array[@key='STRVALUE']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key='STRVALUE']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="STRVALUE">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- 000 Handling field "url" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--person persons org-->
   <!--*[@key='person']/*[@key='url'] | *[@key='URLs'] | array[@key='URLs']/* | *[@key='org']/*[@key='url'] | *[@key='URLs'] | array[@key='URLs']/* | *[@key='persons']/*[@key='url'] | *[@key='URLs'] | array[@key='URLs']/* | *[@key='persons']/*/*[@key='url'] | *[@key='URLs'] | array[@key='URLs']/* -->
   <!--*[@key='url'] | *[@key='URLs'] | array[@key='URLs']/*-->
   <xsl:template match="*[@key='person']/*[@key='url'] | *[@key='URLs'] | array[@key='URLs']/* | *[@key='org']/*[@key='url'] | *[@key='URLs'] | array[@key='URLs']/* | *[@key='persons']/*[@key='url'] | *[@key='URLs'] | array[@key='URLs']/* | *[@key='persons']/*/*[@key='url'] | *[@key='URLs'] | array[@key='URLs']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="url" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='URLs'][array/@key='STRVALUE'] |  array[@key='URLs']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="URLs">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='URLs']/array[@key='STRVALUE']/string |  array[@key='URLs']/map/array[@key='STRVALUE']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key='STRVALUE']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="STRVALUE">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- 000 Handling assembly "notes" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='notes']" priority="4" mode="json2xml">
      <xsl:element name="notes" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key='prose']"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "desc" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--resource resources role roles citation citations-->
   <!--*[@key='resource']/*[@key='desc'] | *[@key='role']/*[@key='desc'] | *[@key='citation']/*[@key='desc'] | *[@key='resources']/*[@key='desc'] | *[@key='resources']/*/*[@key='desc']  | *[@key='roles']/*[@key='desc'] | *[@key='roles']/*/*[@key='desc']  | *[@key='citations']/*[@key='desc'] | *[@key='citations']/*/*[@key='desc'] -->
   <!--*[@key='desc']-->
   <xsl:template match="*[@key='resource']/*[@key='desc'] | *[@key='role']/*[@key='desc'] | *[@key='citation']/*[@key='desc'] | *[@key='resources']/*[@key='desc'] | *[@key='resources']/*/*[@key='desc']  | *[@key='roles']/*[@key='desc'] | *[@key='roles']/*/*[@key='desc']  | *[@key='citations']/*[@key='desc'] | *[@key='citations']/*/*[@key='desc'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="desc" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "resource" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='resource'] | *[@key='resources']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="resource" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('desc')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('rlink', 'rlinks')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('base64')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('notes')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='resources']/*" priority="3" mode="json2xml">
      <xsl:element name="resource" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('desc')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('rlink', 'rlinks')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('base64')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('notes')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "hash" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--rlink rlinks-->
   <!--*[@key='rlink']/*[@key='hash'] | *[@key='hashes'] | array[@key='hashes']/* | *[@key='rlinks']/*[@key='hash'] | *[@key='hashes'] | array[@key='hashes']/* | *[@key='rlinks']/*/*[@key='hash'] | *[@key='hashes'] | array[@key='hashes']/* -->
   <!--*[@key='hash'] | *[@key='hashes'] | array[@key='hashes']/*-->
   <xsl:template match="*[@key='rlink']/*[@key='hash'] | *[@key='hashes'] | array[@key='hashes']/* | *[@key='rlinks']/*[@key='hash'] | *[@key='hashes'] | array[@key='hashes']/* | *[@key='rlinks']/*/*[@key='hash'] | *[@key='hashes'] | array[@key='hashes']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="hash" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='value']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='hashes'][array/@key='value'] |  array[@key='hashes']/map[array/@key='value']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="hashes">
            <xsl:apply-templates mode="expand" select="array[@key='value']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='hashes']/array[@key='value']/string |  array[@key='hashes']/map/array[@key='value']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key='value']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="value">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- 000 Handling flag "algorithm" 000 -->
   <xsl:template match="*[@key='algorithm']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='hash']/*[@key='algorithm'] | *[@key='hashes']/*[@key='algorithm'] | array[@key='hashes']/*/*[@key='algorithm']"
                 mode="as-attribute">
      <xsl:attribute name="algorithm">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling assembly "role" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='role'] | *[@key='roles']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="role" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('short-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('desc')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='roles']/*" priority="3" mode="json2xml">
      <xsl:element name="role" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('short-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('desc')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling flag "href" 000 -->
   <xsl:template match="*[@key='href']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='link']/*[@key='href'] | *[@key='links']/*[@key='href'] | array[@key='links']/*/*[@key='href'] | *[@key='rlink']/*[@key='href'] | *[@key='rlinks']/*[@key='href'] | array[@key='rlinks']/*/*[@key='href']"
                 mode="as-attribute">
      <xsl:attribute name="href">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "id" 000 -->
   <xsl:template match="*[@key='id']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='prop']/*[@key='id'] | *[@key='properties']/*[@key='id'] | array[@key='properties']/*/*[@key='id'] | *[@key='party']/*[@key='id'] | *[@key='parties']/*[@key='id'] | array[@key='parties']/*/*[@key='id'] | *[@key='resource']/*[@key='id'] | *[@key='resources']/*[@key='id'] | array[@key='resources']/*/*[@key='id'] | *[@key='role']/*[@key='id'] | *[@key='roles']/*[@key='id'] | array[@key='roles']/*/*[@key='id'] | *[@key='citation']/*[@key='id'] | *[@key='citations']/*[@key='id'] | array[@key='citations']/*/*[@key='id'] | *[@key='catalog']/*[@key='id'] | *[@key='control-catalog']/*[@key='id'] | array[@key='control-catalog']/*/*[@key='id'] | *[@key='group']/*[@key='id'] | *[@key='groups']/*[@key='id'] | array[@key='groups']/*/*[@key='id'] | *[@key='control']/*[@key='id'] | *[@key='controls']/*[@key='id'] | array[@key='controls']/*/*[@key='id'] | *[@key='subcontrol']/*[@key='id'] | *[@key='subcontrols']/*[@key='id'] | array[@key='subcontrols']/*/*[@key='id'] | *[@key='param']/*[@key='id'] | *[@key='parameters']/*[@key='id'] | array[@key='parameters']/*/*[@key='id'] | *[@key='usage']/*[@key='id'] | *[@key='descriptions']/*[@key='id'] | array[@key='descriptions']/*/*[@key='id'] | *[@key='part']/*[@key='id'] | *[@key='parts']/*[@key='id'] | array[@key='parts']/*/*[@key='id']"
                 mode="as-attribute">
      <xsl:attribute name="id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "role-id" 000 -->
   <xsl:template match="*[@key='role-id']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='party']/*[@key='role-id'] | *[@key='parties']/*[@key='role-id'] | array[@key='parties']/*/*[@key='role-id']"
                 mode="as-attribute">
      <xsl:attribute name="role-id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling field "title" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--metadata role roles citation citations group groups control controls subcontrol subcontrols part parts-->
   <!--*[@key='metadata']/*[@key='title'] | *[@key='role']/*[@key='title'] | *[@key='citation']/*[@key='title'] | *[@key='group']/*[@key='title'] | *[@key='control']/*[@key='title'] | *[@key='subcontrol']/*[@key='title'] | *[@key='part']/*[@key='title'] | *[@key='roles']/*[@key='title'] | *[@key='roles']/*/*[@key='title']  | *[@key='citations']/*[@key='title'] | *[@key='citations']/*/*[@key='title']  | *[@key='groups']/*[@key='title'] | *[@key='groups']/*/*[@key='title']  | *[@key='controls']/*[@key='title'] | *[@key='controls']/*/*[@key='title']  | *[@key='subcontrols']/*[@key='title'] | *[@key='subcontrols']/*/*[@key='title']  | *[@key='parts']/*[@key='title'] | *[@key='parts']/*/*[@key='title'] -->
   <!--*[@key='title']-->
   <xsl:template match="*[@key='metadata']/*[@key='title'] | *[@key='role']/*[@key='title'] | *[@key='citation']/*[@key='title'] | *[@key='group']/*[@key='title'] | *[@key='control']/*[@key='title'] | *[@key='subcontrol']/*[@key='title'] | *[@key='part']/*[@key='title'] | *[@key='roles']/*[@key='title'] | *[@key='roles']/*/*[@key='title']  | *[@key='citations']/*[@key='title'] | *[@key='citations']/*/*[@key='title']  | *[@key='groups']/*[@key='title'] | *[@key='groups']/*/*[@key='title']  | *[@key='controls']/*[@key='title'] | *[@key='controls']/*/*[@key='title']  | *[@key='subcontrols']/*[@key='title'] | *[@key='subcontrols']/*/*[@key='title']  | *[@key='parts']/*[@key='title'] | *[@key='parts']/*/*[@key='title'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="title" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:for-each select="string[@key='RICHTEXT'], self::string">
            <xsl:variable name="markup">
               <xsl:apply-templates mode="infer-inlines"/>
            </xsl:variable>
            <xsl:apply-templates mode="cast-ns" select="$markup"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "base64" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--resource resources-->
   <!--*[@key='resource']/*[@key='base64'] | *[@key='resources']/*[@key='base64'] | *[@key='resources']/*/*[@key='base64'] -->
   <!--*[@key='base64']-->
   <xsl:template match="*[@key='resource']/*[@key='base64'] | *[@key='resources']/*[@key='base64'] | *[@key='resources']/*/*[@key='base64'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="base64" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling flag "filename" 000 -->
   <xsl:template match="*[@key='filename']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='base64']/*[@key='filename']"
                 mode="as-attribute">
      <xsl:attribute name="filename">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling assembly "citation" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='citation'] | *[@key='citations']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="citation" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('target', 'targets')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('desc')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('doc-id', 'document-ids')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='citations']/*" priority="3" mode="json2xml">
      <xsl:element name="citation" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('target', 'targets')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('desc')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('doc-id', 'document-ids')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "target" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--citation citations-->
   <!--*[@key='citation']/*[@key='target'] | *[@key='targets'] | array[@key='targets']/* | *[@key='citations']/*[@key='target'] | *[@key='targets'] | array[@key='targets']/* | *[@key='citations']/*/*[@key='target'] | *[@key='targets'] | array[@key='targets']/* -->
   <!--*[@key='target'] | *[@key='targets'] | array[@key='targets']/*-->
   <xsl:template match="*[@key='citation']/*[@key='target'] | *[@key='targets'] | array[@key='targets']/* | *[@key='citations']/*[@key='target'] | *[@key='targets'] | array[@key='targets']/* | *[@key='citations']/*/*[@key='target'] | *[@key='targets'] | array[@key='targets']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="target" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='targets'][array/@key='STRVALUE'] |  array[@key='targets']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="targets">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='targets']/array[@key='STRVALUE']/string |  array[@key='targets']/map/array[@key='STRVALUE']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key='STRVALUE']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="STRVALUE">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- 000 Handling assembly "catalog" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='catalog'] | *[@key='control-catalog'] | /map[empty(@key)]"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="catalog" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('metadata')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('group', 'groups')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('control', 'controls')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('back-matter')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='control-catalog']/*" priority="3" mode="json2xml">
      <xsl:element name="catalog" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('metadata')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('group', 'groups')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('control', 'controls')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('back-matter')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "group" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='group'] | *[@key='groups']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="group" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('param', 'parameters')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('part', 'parts')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('group', 'groups')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('control', 'controls')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='groups']/*" priority="3" mode="json2xml">
      <xsl:element name="group" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('param', 'parameters')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('part', 'parts')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('group', 'groups')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('control', 'controls')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "control" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='control'] | *[@key='controls']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="control" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('param', 'parameters')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('part', 'parts')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('subcontrol', 'subcontrols')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='controls']/*" priority="3" mode="json2xml">
      <xsl:element name="control" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('param', 'parameters')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('part', 'parts')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('subcontrol', 'subcontrols')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "subcontrol" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='subcontrol'] | *[@key='subcontrols']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="subcontrol" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('param', 'parameters')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('part', 'parts')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='subcontrols']/*" priority="3" mode="json2xml">
      <xsl:element name="subcontrol" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('param', 'parameters')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('part', 'parts')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "param" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='param'] | *[@key='parameters']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="param" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('label')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('usage', 'descriptions')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('constraint', 'constraints')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('guideline', 'guidance')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('value')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('select')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='parameters']/*" priority="3" mode="json2xml">
      <xsl:element name="param" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('label')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('usage', 'descriptions')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('constraint', 'constraints')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('guideline', 'guidance')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('value')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('select')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "label" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--param parameters-->
   <!--*[@key='param']/*[@key='label'] | *[@key='parameters']/*[@key='label'] | *[@key='parameters']/*/*[@key='label'] -->
   <!--*[@key='label']-->
   <xsl:template match="*[@key='param']/*[@key='label'] | *[@key='parameters']/*[@key='label'] | *[@key='parameters']/*/*[@key='label'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="label" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:for-each select="string[@key='RICHTEXT'], self::string">
            <xsl:variable name="markup">
               <xsl:apply-templates mode="infer-inlines"/>
            </xsl:variable>
            <xsl:apply-templates mode="cast-ns" select="$markup"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "usage" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--param parameters-->
   <!--*[@key='param']/*[@key='usage'] | *[@key='descriptions'] | array[@key='descriptions']/* | *[@key='parameters']/*[@key='usage'] | *[@key='descriptions'] | array[@key='descriptions']/* | *[@key='parameters']/*/*[@key='usage'] | *[@key='descriptions'] | array[@key='descriptions']/* -->
   <!--*[@key='usage'] | *[@key='descriptions'] | array[@key='descriptions']/*-->
   <xsl:template match="*[@key='param']/*[@key='usage'] | *[@key='descriptions'] | array[@key='descriptions']/* | *[@key='parameters']/*[@key='usage'] | *[@key='descriptions'] | array[@key='descriptions']/* | *[@key='parameters']/*/*[@key='usage'] | *[@key='descriptions'] | array[@key='descriptions']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="usage" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:for-each select="string[@key='RICHTEXT'], self::string">
            <xsl:variable name="markup">
               <xsl:apply-templates mode="infer-inlines"/>
            </xsl:variable>
            <xsl:apply-templates mode="cast-ns" select="$markup"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='descriptions'][array/@key='RICHTEXT'] |  array[@key='descriptions']/map[array/@key='RICHTEXT']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="descriptions">
            <xsl:apply-templates mode="expand" select="array[@key='RICHTEXT']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='descriptions']/array[@key='RICHTEXT']/string |  array[@key='descriptions']/map/array[@key='RICHTEXT']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key='RICHTEXT']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="RICHTEXT">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- 000 Handling field "constraint" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--param parameters-->
   <!--*[@key='param']/*[@key='constraint'] | *[@key='constraints'] | array[@key='constraints']/* | *[@key='parameters']/*[@key='constraint'] | *[@key='constraints'] | array[@key='constraints']/* | *[@key='parameters']/*/*[@key='constraint'] | *[@key='constraints'] | array[@key='constraints']/* -->
   <!--*[@key='constraint'] | *[@key='constraints'] | array[@key='constraints']/*-->
   <xsl:template match="*[@key='param']/*[@key='constraint'] | *[@key='constraints'] | array[@key='constraints']/* | *[@key='parameters']/*[@key='constraint'] | *[@key='constraints'] | array[@key='constraints']/* | *[@key='parameters']/*/*[@key='constraint'] | *[@key='constraints'] | array[@key='constraints']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="constraint" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='constraints'][array/@key='STRVALUE'] |  array[@key='constraints']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="constraints">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='constraints']/array[@key='STRVALUE']/string |  array[@key='constraints']/map/array[@key='STRVALUE']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key='STRVALUE']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="STRVALUE">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- 000 Handling assembly "guideline" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='guideline'] | *[@key='guidance']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="guideline" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key='prose']"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='guidance']/*" priority="3" mode="json2xml">
      <xsl:element name="guideline" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key='prose']"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "value" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--param parameters-->
   <!--*[@key='param']/*[@key='value'] | *[@key='parameters']/*[@key='value'] | *[@key='parameters']/*/*[@key='value'] -->
   <!--*[@key='value']-->
   <xsl:template match="*[@key='param']/*[@key='value'] | *[@key='parameters']/*[@key='value'] | *[@key='parameters']/*/*[@key='value'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="value" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:for-each select="string[@key='RICHTEXT'], self::string">
            <xsl:variable name="markup">
               <xsl:apply-templates mode="infer-inlines"/>
            </xsl:variable>
            <xsl:apply-templates mode="cast-ns" select="$markup"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "select" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='select']" priority="4" mode="json2xml">
      <xsl:element name="select" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('choice', 'alternatives')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "choice" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--select-->
   <!--*[@key='select']/*[@key='choice'] | *[@key='alternatives'] | array[@key='alternatives']/*-->
   <!--*[@key='choice'] | *[@key='alternatives'] | array[@key='alternatives']/*-->
   <xsl:template match="*[@key='select']/*[@key='choice'] | *[@key='alternatives'] | array[@key='alternatives']/*"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="choice" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:for-each select="string[@key='RICHTEXT'], self::string">
            <xsl:variable name="markup">
               <xsl:apply-templates mode="infer-inlines"/>
            </xsl:variable>
            <xsl:apply-templates mode="cast-ns" select="$markup"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='alternatives'][array/@key='RICHTEXT'] |  array[@key='alternatives']/map[array/@key='RICHTEXT']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="alternatives">
            <xsl:apply-templates mode="expand" select="array[@key='RICHTEXT']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='alternatives']/array[@key='RICHTEXT']/string |  array[@key='alternatives']/map/array[@key='RICHTEXT']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key='RICHTEXT']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="RICHTEXT">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- 000 Handling assembly "part" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='part'] | *[@key='parts']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="part" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key='prose']"/>
         <xsl:apply-templates mode="#current" select="*[@key=('part', 'parts')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='parts']/*" priority="3" mode="json2xml">
      <xsl:element name="part" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key='prose']"/>
         <xsl:apply-templates mode="#current" select="*[@key=('part', 'parts')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling flag "test" 000 -->
   <xsl:template match="*[@key='test']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='constraint']/*[@key='test'] | *[@key='constraints']/*[@key='test'] | array[@key='constraints']/*/*[@key='test']"
                 mode="as-attribute">
      <xsl:attribute name="test">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "how-many" 000 -->
   <xsl:template match="*[@key='how-many']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='select']/*[@key='how-many']"
                 mode="as-attribute">
      <xsl:attribute name="how-many">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "depends-on" 000 -->
   <xsl:template match="*[@key='depends-on']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='param']/*[@key='depends-on'] | *[@key='parameters']/*[@key='depends-on'] | array[@key='parameters']/*/*[@key='depends-on']"
                 mode="as-attribute">
      <xsl:attribute name="depends-on">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 00000000000000000000000000000000000000000000000000000000000000 -->
   <!-- Markdown converter-->
   <xsl:output indent="yes"/>
   <xsl:template name="parse"><!-- First, group according to ``` delimiters btw codeblocks and not
        within codeblock, escape & and < (only)
        within not-codeblock split lines at \n\s*\n
        
        --><!-- $str may be passed in, or we can process the current node -->
      <xsl:param name="markdown-str" as="xs:string" required="yes"/>
      <xsl:variable name="str" select="string($markdown-str) =&gt; replace('\\n','&#xA;')"/>
      <xsl:variable name="starts-with-code" select="matches($str,'^```')"/>
      <!-- Blocks is split between code blocks and everything else -->
      <xsl:variable name="blocks">
         <xsl:for-each-group select="tokenize($str, '\n')"
                             group-starting-with=".[matches(., '^```')]">
            <xsl:variable name="this-is-code"
                          select="not((position() mod 2) + number($starts-with-code))"/>
            <m:p><!-- Adding an attribute flag when this is a code block, code='code' -->
               <xsl:if test="$this-is-code">
                  <xsl:variable name="language"
                                expand-text="true"
                                select="(replace(.,'^```','') ! normalize-space(.))[matches(.,'\S')]"/>
                  <xsl:attribute name="code" select="if ($language) then $language else 'code'"/>
               </xsl:if>
               <xsl:value-of select="string-join(current-group()[not(matches(., '^```'))],'&#xA;')"/>
            </m:p>
         </xsl:for-each-group>
      </xsl:variable>
      <xsl:variable name="rough-blocks">
         <xsl:apply-templates select="$blocks" mode="parse-block"/>
      </xsl:variable>
      <xsl:variable name="flat-structures">
         <xsl:apply-templates select="$rough-blocks" mode="mark-structures"/>
      </xsl:variable>
      <!--<xsl:copy-of select="$flat-structures"/>-->
      <xsl:variable name="nested-structures">
         <xsl:apply-templates select="$flat-structures" mode="build-structures"/>
      </xsl:variable>
      <xsl:variable name="fully-marked">
         <xsl:apply-templates select="$nested-structures" mode="infer-inlines"/>
      </xsl:variable>
      <xsl:apply-templates select="$fully-marked" mode="cast-ns"/>
   </xsl:template>
   <xsl:template match="*" mode="copy mark-structures build-structures infer-inlines">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates mode="#current"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template mode="parse-block"
                 priority="1"
                 match="m:p[exists(@code)]"
                 expand-text="true">
      <xsl:element name="m:pre" namespace="{ $target-ns }">
         <xsl:element name="code" namespace="{ $target-ns }">
            <xsl:for-each select="@code[not(.='code')]">
               <xsl:attribute name="class">language-{.}</xsl:attribute>
            </xsl:for-each>
            <xsl:value-of select="string(.)"/>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template mode="parse-block" match="m:p" expand-text="true">
      <xsl:for-each select="tokenize(string(.),'\n\s*\n')[normalize-space(.)]">
         <m:p>
            <xsl:value-of select="replace(.,'^\s*\n','')"/>
         </m:p>
      </xsl:for-each>
   </xsl:template>
   <xsl:function name="m:is-table-row-demarcator" as="xs:boolean">
      <xsl:param name="line" as="xs:string"/>
      <xsl:sequence select="matches($line,'^[\|\-:\s]+$')"/>
   </xsl:function>
   <xsl:function name="m:is-table" as="xs:boolean">
      <xsl:param name="line" as="element(m:p)"/>
      <xsl:variable name="lines" select="tokenize($line,'\s*\n')[matches(.,'\S')]"/>
      <xsl:sequence select="(every $l in $lines satisfies matches($l,'^\|'))             and (some $l in $lines satisfies m:is-table-row-demarcator($l))"/>
   </xsl:function>
   <xsl:template mode="mark-structures" priority="5" match="m:p[m:is-table(.)]">
      <xsl:variable name="rows">
         <xsl:for-each select="tokenize(string(.),'\s*\n')">
            <m:tr>
               <xsl:value-of select="."/>
            </m:tr>
         </xsl:for-each>
      </xsl:variable>
      <m:table>
         <xsl:apply-templates select="$rows/m:tr" mode="make-row"/>
      </m:table>
   </xsl:template>
   <xsl:template match="m:tr[m:is-table-row-demarcator(string(.))]"
                 priority="5"
                 mode="make-row"/>
   <xsl:template match="m:tr" mode="make-row">
      <m:tr>
         <xsl:for-each select="tokenize(string(.), '\s*\|\s*')[not(position() = (1,last())) ]">
            <m:td>
               <xsl:value-of select="."/>
            </m:td>
         </xsl:for-each>
      </m:tr>
   </xsl:template>
   <xsl:template match="m:tr[some $f in (following-sibling::tr) satisfies m:is-table-row-demarcator(string($f))]"
                 mode="make-row">
      <m:tr>
         <xsl:for-each select="tokenize(string(.), '\s*\|\s*')[not(position() = (1,last())) ]">
            <m:th>
               <xsl:value-of select="."/>
            </m:th>
         </xsl:for-each>
      </m:tr>
   </xsl:template>
   <xsl:template mode="mark-structures" match="m:p[matches(.,'^#')]"><!-- 's' flag is dot-matches-all, so \n does not impede -->
      <m:p header-level="{ replace(.,'[^#].*$','','s') ! string-length(.) }">
         <xsl:value-of select="replace(.,'^#+\s*','') ! replace(.,'\s+$','')"/>
      </m:p>
   </xsl:template>
   <xsl:variable name="li-regex" as="xs:string">^\s*(\*|\d+\.)\s</xsl:variable>
   <xsl:template mode="mark-structures" match="m:p[matches(.,$li-regex)]">
      <m:list>
         <xsl:for-each-group group-starting-with=".[matches(.,$li-regex)]"
                             select="tokenize(., '\n')">
            <m:li level="{ replace(.,'\S.*$','') ! floor(string-length(.) div 2)}"
                  type="{ if (matches(.,'\s*\d')) then 'ol' else 'ul' }">
               <xsl:for-each select="current-group()[normalize-space(.)]">
                  <xsl:if test="not(position() eq 1)">
                     <m:br/>
                  </xsl:if>
                  <xsl:value-of select="replace(., $li-regex, '')"/>
               </xsl:for-each>
            </m:li>
         </xsl:for-each-group>
      </m:list>
   </xsl:template>
   <xsl:template mode="build-structures" match="m:p[@header-level]">
      <xsl:variable name="level" select="(@header-level[6 &gt;= .],6)[1]"/>
      <xsl:element name="m:h{$level}"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0/md-convertor">
         <xsl:value-of select="."/>
      </xsl:element>
   </xsl:template>
   <xsl:template mode="build-structures" match="m:list" name="nest-lists"><!-- Starting at level 0 and grouping  --><!--        -->
      <xsl:param name="level" select="0"/>
      <xsl:param name="group" select="m:li"/>
      <xsl:variable name="this-type" select="$group[1]/@type"/>
      <!-- first, splitting ul from ol groups -->
      <xsl:for-each-group select="$group"
                          group-starting-with="*[@level = $level and not(@type = preceding-sibling::*/@type)]">
         <xsl:element name="m:{ $group[1]/@type }"
                      namespace="http://csrc.nist.gov/ns/oscal/1.0/md-convertor">
            <xsl:for-each-group select="current-group()" group-starting-with="li[@level = $level]">
               <xsl:choose>
                  <xsl:when test="@level = $level (: checking first item in group :)">
                     <m:li><!--<xsl:copy-of select="@level"/>-->
                        <xsl:apply-templates mode="copy"/>
                        <xsl:if test="current-group()/@level &gt; $level (: go deeper? :)">
                           <xsl:call-template name="nest-lists">
                              <xsl:with-param name="level" select="$level + 1"/>
                              <xsl:with-param name="group" select="current-group()[@level &gt; $level]"/>
                           </xsl:call-template>
                        </xsl:if>
                     </m:li>
                  </xsl:when>
                  <xsl:otherwise><!-- fallback for skipping levels -->
                     <m:li><!-- level="{$level}"-->
                        <xsl:call-template name="nest-lists">
                           <xsl:with-param name="level" select="$level + 1"/>
                           <xsl:with-param name="group" select="current-group()"/>
                        </xsl:call-template>
                     </m:li>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each-group>
         </xsl:element>
      </xsl:for-each-group>
   </xsl:template>
   <xsl:template match="m:pre//text()" mode="infer-inlines">
      <xsl:copy-of select="."/>
   </xsl:template>
   <xsl:template match="text()" mode="infer-inlines">
      <xsl:variable name="markup">
         <xsl:apply-templates select="$tag-replacements/m:rules">
            <xsl:with-param name="original" tunnel="yes" as="text()" select="."/>
         </xsl:apply-templates>
      </xsl:variable>
      <xsl:try select="parse-xml-fragment($markup)">
         <xsl:catch select="."/>
      </xsl:try>
   </xsl:template>
   <xsl:template mode="cast-ns" match="*">
      <xsl:element name="{local-name()}" namespace="{ $target-ns }">
         <xsl:copy-of select="@*[matches(.,'\S')]"/>
         <xsl:apply-templates mode="#current"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="m:rules" as="xs:string"><!-- Original is only provided for processing text nodes -->
      <xsl:param name="original" as="text()?" tunnel="yes"/>
      <xsl:param name="starting" as="xs:string" select="string($original)"/>
      <xsl:iterate select="*">
         <xsl:param name="original" select="$original" as="text()?"/>
         <xsl:param name="str" select="$starting" as="xs:string"/>
         <xsl:on-completion select="$str"/>
         <xsl:next-iteration>
            <xsl:with-param name="str">
               <xsl:apply-templates select=".">
                  <xsl:with-param name="str" select="$str"/>
               </xsl:apply-templates>
            </xsl:with-param>
         </xsl:next-iteration>
      </xsl:iterate>
   </xsl:template>
   <xsl:template match="m:replace" expand-text="true">
      <xsl:param name="str" as="xs:string"/>
      <!--<xsl:value-of>replace({$str},{@match},{string(.)})</xsl:value-of>-->
      <xsl:sequence select="replace($str, @match, string(.))"/>
      <!--<xsl:copy-of select="."/>-->
   </xsl:template>
   <xsl:variable xmlns="http://csrc.nist.gov/ns/oscal/1.0/md-convertor"
                 name="tag-replacements">
      <rules><!-- first, literal replacements --><!--<replace match="&amp;"  >&amp;amp;</replace>-->
         <replace match="&lt;">&amp;lt;</replace>
         <!-- next, explicit escape sequences -->
         <replace match="\\&#34;">&amp;quot;</replace>
         <replace match="\\'">&amp;apos;</replace>
         <replace match="\\\*">&amp;#2A;</replace>
         <replace match="\\`">&amp;#60;</replace>
         <replace match="\\~">&amp;#7E;</replace>
         <replace match="\\^">&amp;#5E;</replace>
         <!-- then, replacements based on $tag-specification -->
         <xsl:for-each select="$tag-specification/*">
            <xsl:variable name="match-expr">
               <xsl:apply-templates select="." mode="write-match"/>
            </xsl:variable>
            <xsl:variable name="repl-expr">
               <xsl:apply-templates select="." mode="write-replace"/>
            </xsl:variable>
            <replace match="{$match-expr}">
               <xsl:sequence select="$repl-expr"/>
            </replace>
         </xsl:for-each>
      </rules>
   </xsl:variable>
   <xsl:variable xmlns="http://csrc.nist.gov/ns/oscal/1.0/md-convertor"
                 name="tag-specification"
                 as="element(m:tag-spec)">
      <tag-spec><!-- The XML notation represents the substitution by showing both delimiters and tags  --><!-- Note that text contents are regex notation for matching so * must be \* -->
         <q>"<text/>"</q>
         <img alt="!\[{{$text}}\]" src="\({{$text}}\)"/>
         <insert param-id="\{{{{$nws}}\}}"/>
         <a href="\[{{$text}}\]">\(<text/>\)</a>
         <code>`<text/>`</code>
         <strong>
            <em>\*\*\*<text/>\*\*\*</em>
         </strong>
         <strong>\*\*<text/>\*\*</strong>
         <em>\*<text/>\*</em>
         <sub>~<text/>~</sub>
         <sup>\^<text/>\^</sup>
      </tag-spec>
   </xsl:variable>
   <xsl:template match="*" mode="write-replace"><!-- we can write an open/close pair even for an empty element b/c
             it will be parsed and serialized -->
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="local-name()"/>
      <!-- coercing the order to ensure correct formation of regegex       -->
      <xsl:apply-templates mode="#current" select="@*"/>
      <xsl:text>&gt;</xsl:text>
      <xsl:apply-templates mode="#current" select="*"/>
      <xsl:text>&lt;/</xsl:text>
      <xsl:value-of select="local-name()"/>
      <xsl:text>&gt;</xsl:text>
   </xsl:template>
   <xsl:template match="*" mode="write-match">
      <xsl:apply-templates select="@*, node()" mode="write-match"/>
   </xsl:template>
   <xsl:template match="@*[matches(., '\{\$text\}')]" mode="write-match">
      <xsl:value-of select="replace(., '\{\$text\}', '(.*)?')"/>
   </xsl:template>
   <xsl:template match="@*[matches(., '\{\$nws\}')]" mode="write-match"><!--<xsl:value-of select="."/>--><!--<xsl:value-of select="replace(., '\{\$nws\}', '(\S*)?')"/>-->
      <xsl:value-of select="replace(., '\{\$nws\}', '\\s*(\\S+)?\\s*')"/>
   </xsl:template>
   <xsl:template match="m:text" mode="write-replace">
      <xsl:text>$1</xsl:text>
   </xsl:template>
   <xsl:template match="m:insert/@param-id" mode="write-replace">
      <xsl:text> param-id='$1'</xsl:text>
   </xsl:template>
   <xsl:template match="m:a/@href" mode="write-replace">
      <xsl:text> href='$2'</xsl:text>
      <!--<xsl:value-of select="replace(.,'\{\$insert\}','\$2')"/>-->
   </xsl:template>
   <xsl:template match="m:img/@alt" mode="write-replace">
      <xsl:text> alt='$1'</xsl:text>
      <!--<xsl:value-of select="replace(.,'\{\$insert\}','\$2')"/>-->
   </xsl:template>
   <xsl:template match="m:img/@src" mode="write-replace">
      <xsl:text> src='$2'</xsl:text>
      <!--<xsl:value-of select="replace(.,'\{\$insert\}','\$2')"/>-->
   </xsl:template>
   <xsl:template match="m:text" mode="write-match">
      <xsl:text>(.*?)</xsl:text>
   </xsl:template>
   <xsl:variable name="line-example" xml:space="preserve"> { insertion } </xsl:variable>
</xsl:stylesheet>
