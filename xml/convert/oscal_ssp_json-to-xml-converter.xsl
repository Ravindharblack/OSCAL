<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:m="http://csrc.nist.gov/ns/oscal/1.0/md-convertor"
                version="3.0"
                xpath-default-namespace="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="#all">
   <xsl:output indent="yes" method="xml"/>
   <!-- OSCAL system-security-plan conversion stylesheet supports JSON->XML conversion -->
   <xsl:param name="target-ns"
              as="xs:string?"
              select="'urn:OSCAL-SSP-metaschema'"/>
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
      <xsl:apply-templates mode="#current" select="*[@key=('system-security-plan')]"/>
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
      <xsl:element name="metadata" namespace="urn:OSCAL-SSP-metaschema">
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
      <xsl:element name="back-matter" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('citation', 'citations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('resource', 'resources')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "last-modified-date" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--metadata-->
   <!--*[@key='metadata']/*[@key='last-modified-date']-->
   <!--*[@key='last-modified-date']-->
   <xsl:template match="*[@key='metadata']/*[@key='last-modified-date']"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="last-modified-date" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "version" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--metadata origin ssp-origin attachment-->
   <!--*[@key='metadata']/*[@key='version'] | *[@key='origin']/*[@key='version'] | *[@key='attachment']/*[@key='version'] | *[@key='ssp-origin']/*[@key='version'] | *[@key='ssp-origin']/*/*[@key='version'] -->
   <!--*[@key='version']-->
   <xsl:template match="*[@key='metadata']/*[@key='version'] | *[@key='origin']/*[@key='version'] | *[@key='attachment']/*[@key='version'] | *[@key='ssp-origin']/*[@key='version'] | *[@key='ssp-origin']/*/*[@key='version'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="version" namespace="urn:OSCAL-SSP-metaschema">
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
      <xsl:element name="oscal-version" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "doc-id" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--metadata-->
   <!--*[@key='metadata']/*[@key='doc-id'] | *[@key='document-ids'] | array[@key='document-ids']/*-->
   <!--*[@key='doc-id'] | *[@key='document-ids'] | array[@key='document-ids']/*-->
   <xsl:template match="*[@key='metadata']/*[@key='doc-id'] | *[@key='document-ids'] | array[@key='document-ids']/*"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="doc-id" namespace="urn:OSCAL-SSP-metaschema">
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
   <!-- 000 Handling field "prop" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--metadata host-item ssp-host-item control controls-->
   <!--*[@key='metadata']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='host-item']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='control']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='ssp-host-item']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='ssp-host-item']/*/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/*  | *[@key='controls']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='controls']/*/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* -->
   <!--*[@key='prop'] | *[@key='properties'] | array[@key='properties']/*-->
   <xsl:template match="*[@key='metadata']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='host-item']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='control']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='ssp-host-item']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='ssp-host-item']/*/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/*  | *[@key='controls']/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* | *[@key='controls']/*/*[@key='prop'] | *[@key='properties'] | array[@key='properties']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="prop" namespace="urn:OSCAL-SSP-metaschema">
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
   <!-- 000 Handling flag "ns" 000 -->
   <xsl:template match="*[@key='ns']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='prop']/*[@key='ns'] | *[@key='properties']/*[@key='ns'] | array[@key='properties']/*/*[@key='ns']"
                 mode="as-attribute">
      <xsl:attribute name="ns">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling assembly "party" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='party'] | *[@key='parties']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="party" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('person', 'persons')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('org')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('notes')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='parties']/*" priority="3" mode="json2xml">
      <xsl:element name="party" namespace="urn:OSCAL-SSP-metaschema">
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
      <xsl:element name="person" namespace="urn:OSCAL-SSP-metaschema">
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
      <xsl:element name="person" namespace="urn:OSCAL-SSP-metaschema">
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
      <xsl:element name="org" namespace="urn:OSCAL-SSP-metaschema">
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
      <xsl:element name="person-id" namespace="urn:OSCAL-SSP-metaschema">
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
      <xsl:element name="org-id" namespace="urn:OSCAL-SSP-metaschema">
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
      <xsl:element name="rlink" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('hash', 'hashes')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='rlinks']/*" priority="3" mode="json2xml">
      <xsl:element name="rlink" namespace="urn:OSCAL-SSP-metaschema">
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
                 match="*[@key='rlink']/*[@key='media-type'] | *[@key='rlinks']/*[@key='media-type'] | array[@key='rlinks']/*/*[@key='media-type']"
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
      <xsl:element name="person-name" namespace="urn:OSCAL-SSP-metaschema">
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
      <xsl:element name="org-name" namespace="urn:OSCAL-SSP-metaschema">
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
      <xsl:element name="short-name" namespace="urn:OSCAL-SSP-metaschema">
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
      <xsl:element name="address" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('addr-line', 'postal-address')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('city')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('state')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('postal-code')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('country')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='addresses']/*" priority="3" mode="json2xml">
      <xsl:element name="address" namespace="urn:OSCAL-SSP-metaschema">
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
      <xsl:element name="addr-line" namespace="urn:OSCAL-SSP-metaschema">
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
      <xsl:element name="city" namespace="urn:OSCAL-SSP-metaschema">
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
      <xsl:element name="state" namespace="urn:OSCAL-SSP-metaschema">
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
      <xsl:element name="postal-code" namespace="urn:OSCAL-SSP-metaschema">
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
      <xsl:element name="country" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "email" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--person persons org part ssp-part-->
   <!--*[@key='person']/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/* | *[@key='org']/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/* | *[@key='part']/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/* | *[@key='persons']/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/* | *[@key='persons']/*/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/*  | *[@key='ssp-part']/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/* | *[@key='ssp-part']/*/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/* -->
   <!--*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/*-->
   <xsl:template match="*[@key='person']/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/* | *[@key='org']/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/* | *[@key='part']/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/* | *[@key='persons']/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/* | *[@key='persons']/*/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/*  | *[@key='ssp-part']/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/* | *[@key='ssp-part']/*/*[@key='email'] | *[@key='email-addresses'] | array[@key='email-addresses']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="email" namespace="urn:OSCAL-SSP-metaschema">
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
   <!--person persons org part ssp-part-->
   <!--*[@key='person']/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/* | *[@key='org']/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/* | *[@key='part']/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/* | *[@key='persons']/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/* | *[@key='persons']/*/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/*  | *[@key='ssp-part']/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/* | *[@key='ssp-part']/*/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/* -->
   <!--*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/*-->
   <xsl:template match="*[@key='person']/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/* | *[@key='org']/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/* | *[@key='part']/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/* | *[@key='persons']/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/* | *[@key='persons']/*/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/*  | *[@key='ssp-part']/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/* | *[@key='ssp-part']/*/*[@key='phone'] | *[@key='telephone-numbers'] | array[@key='telephone-numbers']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="phone" namespace="urn:OSCAL-SSP-metaschema">
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
      <xsl:element name="url" namespace="urn:OSCAL-SSP-metaschema">
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
      <xsl:element name="notes" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key='prose']"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "desc" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--resource resources role roles-->
   <!--*[@key='resource']/*[@key='desc'] | *[@key='role']/*[@key='desc'] | *[@key='resources']/*[@key='desc'] | *[@key='resources']/*/*[@key='desc']  | *[@key='roles']/*[@key='desc'] | *[@key='roles']/*/*[@key='desc'] -->
   <!--*[@key='desc']-->
   <xsl:template match="*[@key='resource']/*[@key='desc'] | *[@key='role']/*[@key='desc'] | *[@key='resources']/*[@key='desc'] | *[@key='resources']/*/*[@key='desc']  | *[@key='roles']/*[@key='desc'] | *[@key='roles']/*/*[@key='desc'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="desc" namespace="urn:OSCAL-SSP-metaschema">
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
      <xsl:element name="resource" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('desc')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('rlink', 'rlinks')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('base64')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('notes')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='resources']/*" priority="3" mode="json2xml">
      <xsl:element name="resource" namespace="urn:OSCAL-SSP-metaschema">
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
      <xsl:element name="hash" namespace="urn:OSCAL-SSP-metaschema">
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
   <!-- 000 Handling flag "href" 000 -->
   <xsl:template match="*[@key='href']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='rlink']/*[@key='href'] | *[@key='rlinks']/*[@key='href'] | array[@key='rlinks']/*/*[@key='href'] | *[@key='import']/*[@key='href'] | *[@key='imports']/*[@key='href'] | array[@key='imports']/*/*[@key='href'] | *[@key='part']/*[@key='href'] | *[@key='ssp-part']/*[@key='href'] | array[@key='ssp-part']/*/*[@key='href'] | *[@key='control']/*[@key='href'] | *[@key='controls']/*[@key='href'] | array[@key='controls']/*/*[@key='href'] | *[@key='citation']/*[@key='href'] | *[@key='citations']/*[@key='href'] | array[@key='citations']/*/*[@key='href'] | *[@key='link']/*[@key='href'] | *[@key='links']/*[@key='href'] | array[@key='links']/*/*[@key='href']"
                 mode="as-attribute">
      <xsl:attribute name="href">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling field "title" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--metadata designation ssp-designation role roles origin ssp-origin attachment-->
   <!--*[@key='metadata']/*[@key='title'] | *[@key='designation']/*[@key='title'] | *[@key='role']/*[@key='title'] | *[@key='origin']/*[@key='title'] | *[@key='attachment']/*[@key='title'] | *[@key='ssp-designation']/*[@key='title'] | *[@key='ssp-designation']/*/*[@key='title']  | *[@key='roles']/*[@key='title'] | *[@key='roles']/*/*[@key='title']  | *[@key='ssp-origin']/*[@key='title'] | *[@key='ssp-origin']/*/*[@key='title'] -->
   <!--*[@key='title']-->
   <xsl:template match="*[@key='metadata']/*[@key='title'] | *[@key='designation']/*[@key='title'] | *[@key='role']/*[@key='title'] | *[@key='origin']/*[@key='title'] | *[@key='attachment']/*[@key='title'] | *[@key='ssp-designation']/*[@key='title'] | *[@key='ssp-designation']/*/*[@key='title']  | *[@key='roles']/*[@key='title'] | *[@key='roles']/*/*[@key='title']  | *[@key='ssp-origin']/*[@key='title'] | *[@key='ssp-origin']/*/*[@key='title'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="title" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:for-each select="string[@key='RICHTEXT'], self::string">
            <xsl:variable name="markup">
               <xsl:apply-templates mode="infer-inlines"/>
            </xsl:variable>
            <xsl:apply-templates mode="cast-ns" select="$markup"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "import" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='import'] | *[@key='imports']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="import" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('include', 'includes')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('exclude', 'excludes')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='imports']/*" priority="3" mode="json2xml">
      <xsl:element name="import" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('include', 'includes')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('exclude', 'excludes')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "include" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='include'] | *[@key='includes']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="include" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('all')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('call', 'id-selectors')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('match', 'pattern-selectors')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='includes']/*" priority="3" mode="json2xml">
      <xsl:element name="include" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('all')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('call', 'id-selectors')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('match', 'pattern-selectors')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "all" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--include includes-->
   <!--*[@key='include']/*[@key='all'] | *[@key='includes']/*[@key='all'] | *[@key='includes']/*/*[@key='all'] -->
   <!--*[@key='all']-->
   <xsl:template match="*[@key='include']/*[@key='all'] | *[@key='includes']/*[@key='all'] | *[@key='includes']/*/*[@key='all'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="all" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "call" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--include includes exclude excludes-->
   <!--*[@key='include']/*[@key='call'] | *[@key='id-selectors'] | array[@key='id-selectors']/* | *[@key='exclude']/*[@key='call'] | *[@key='id-selectors'] | array[@key='id-selectors']/* | *[@key='includes']/*[@key='call'] | *[@key='id-selectors'] | array[@key='id-selectors']/* | *[@key='includes']/*/*[@key='call'] | *[@key='id-selectors'] | array[@key='id-selectors']/*  | *[@key='excludes']/*[@key='call'] | *[@key='id-selectors'] | array[@key='id-selectors']/* | *[@key='excludes']/*/*[@key='call'] | *[@key='id-selectors'] | array[@key='id-selectors']/* -->
   <!--*[@key='call'] | *[@key='id-selectors'] | array[@key='id-selectors']/*-->
   <xsl:template match="*[@key='include']/*[@key='call'] | *[@key='id-selectors'] | array[@key='id-selectors']/* | *[@key='exclude']/*[@key='call'] | *[@key='id-selectors'] | array[@key='id-selectors']/* | *[@key='includes']/*[@key='call'] | *[@key='id-selectors'] | array[@key='id-selectors']/* | *[@key='includes']/*/*[@key='call'] | *[@key='id-selectors'] | array[@key='id-selectors']/*  | *[@key='excludes']/*[@key='call'] | *[@key='id-selectors'] | array[@key='id-selectors']/* | *[@key='excludes']/*/*[@key='call'] | *[@key='id-selectors'] | array[@key='id-selectors']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="call" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='id-selectors'][array/@key='STRVALUE'] |  array[@key='id-selectors']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="id-selectors">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='id-selectors']/array[@key='STRVALUE']/string |  array[@key='id-selectors']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling field "match" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--include includes exclude excludes-->
   <!--*[@key='include']/*[@key='match'] | *[@key='pattern-selectors'] | array[@key='pattern-selectors']/* | *[@key='exclude']/*[@key='match'] | *[@key='pattern-selectors'] | array[@key='pattern-selectors']/* | *[@key='includes']/*[@key='match'] | *[@key='pattern-selectors'] | array[@key='pattern-selectors']/* | *[@key='includes']/*/*[@key='match'] | *[@key='pattern-selectors'] | array[@key='pattern-selectors']/*  | *[@key='excludes']/*[@key='match'] | *[@key='pattern-selectors'] | array[@key='pattern-selectors']/* | *[@key='excludes']/*/*[@key='match'] | *[@key='pattern-selectors'] | array[@key='pattern-selectors']/* -->
   <!--*[@key='match'] | *[@key='pattern-selectors'] | array[@key='pattern-selectors']/*-->
   <xsl:template match="*[@key='include']/*[@key='match'] | *[@key='pattern-selectors'] | array[@key='pattern-selectors']/* | *[@key='exclude']/*[@key='match'] | *[@key='pattern-selectors'] | array[@key='pattern-selectors']/* | *[@key='includes']/*[@key='match'] | *[@key='pattern-selectors'] | array[@key='pattern-selectors']/* | *[@key='includes']/*/*[@key='match'] | *[@key='pattern-selectors'] | array[@key='pattern-selectors']/*  | *[@key='excludes']/*[@key='match'] | *[@key='pattern-selectors'] | array[@key='pattern-selectors']/* | *[@key='excludes']/*/*[@key='match'] | *[@key='pattern-selectors'] | array[@key='pattern-selectors']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="match" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='pattern-selectors'][array/@key='STRVALUE'] |  array[@key='pattern-selectors']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="pattern-selectors">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='pattern-selectors']/array[@key='STRVALUE']/string |  array[@key='pattern-selectors']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling assembly "exclude" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='exclude'] | *[@key='excludes']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="exclude" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('call', 'id-selectors')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('match', 'pattern-selectors')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='excludes']/*" priority="3" mode="json2xml">
      <xsl:element name="exclude" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('call', 'id-selectors')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('match', 'pattern-selectors')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling flag "with-control" 000 -->
   <xsl:template match="*[@key='with-control']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='call']/*[@key='with-control'] | *[@key='id-selectors']/*[@key='with-control'] | array[@key='id-selectors']/*/*[@key='with-control'] | *[@key='match']/*[@key='with-control'] | *[@key='pattern-selectors']/*[@key='with-control'] | array[@key='pattern-selectors']/*/*[@key='with-control']"
                 mode="as-attribute">
      <xsl:attribute name="with-control">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "with-subcontrols" 000 -->
   <xsl:template match="*[@key='with-subcontrols']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='all']/*[@key='with-subcontrols'] | *[@key='call']/*[@key='with-subcontrols'] | *[@key='id-selectors']/*[@key='with-subcontrols'] | array[@key='id-selectors']/*/*[@key='with-subcontrols'] | *[@key='match']/*[@key='with-subcontrols'] | *[@key='pattern-selectors']/*[@key='with-subcontrols'] | array[@key='pattern-selectors']/*/*[@key='with-subcontrols']"
                 mode="as-attribute">
      <xsl:attribute name="with-subcontrols">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "subcontrol-id" 000 -->
   <xsl:template match="*[@key='subcontrol-id']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='call']/*[@key='subcontrol-id'] | *[@key='id-selectors']/*[@key='subcontrol-id'] | array[@key='id-selectors']/*/*[@key='subcontrol-id']"
                 mode="as-attribute">
      <xsl:attribute name="subcontrol-id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "pattern" 000 -->
   <xsl:template match="*[@key='pattern']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='match']/*[@key='pattern'] | *[@key='pattern-selectors']/*[@key='pattern'] | array[@key='pattern-selectors']/*/*[@key='pattern']"
                 mode="as-attribute">
      <xsl:attribute name="pattern">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "order" 000 -->
   <xsl:template match="*[@key='order']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='match']/*[@key='order'] | *[@key='pattern-selectors']/*[@key='order'] | array[@key='pattern-selectors']/*/*[@key='order']"
                 mode="as-attribute">
      <xsl:attribute name="order">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling assembly "system-security-plan" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='system-security-plan'] | *[@key='ssp'] | /map[empty(@key)]"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="system-security-plan" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('metadata')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('import', 'imports')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('system-characteristics', 'ssp-system-characteristics')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('system-implementation', 'ssp-system-implementation')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('control-implementation', 'ssp-control-implementation')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('references')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('attachment')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('back-matter')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp']/*" priority="3" mode="json2xml">
      <xsl:element name="system-security-plan" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('metadata')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('import', 'imports')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('system-characteristics', 'ssp-system-characteristics')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('system-implementation', 'ssp-system-implementation')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('control-implementation', 'ssp-control-implementation')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('references')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('attachment')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('back-matter')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "system-characteristics" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='system-characteristics'] | *[@key='ssp-system-characteristics']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="system-characteristics" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('system-id')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('system-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('system-name-short')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('security-sensitivity-level')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('system-information', 'ssp-system-information')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('security-impact-level', 'ssp-security-impact-level')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('security-eauth', 'ssp-security-eauth')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('status')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('status-other-description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('deployment-model')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('deployment-model-other-description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('service-model', 'service-models')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('service-model-other-description', 'service-model-descriptions')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('leveraged-authorizations', 'ssp-leveraged-authorizations')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('authorization-boundary', 'ssp-authorization-boundary')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('network-architecture', 'ssp-network-architecture')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('data-flow', 'ssp-data-flow')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('users', 'ssp-users')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-system-characteristics']/*"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="system-characteristics" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('system-id')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('system-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('system-name-short')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('security-sensitivity-level')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('system-information', 'ssp-system-information')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('security-impact-level', 'ssp-security-impact-level')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('security-eauth', 'ssp-security-eauth')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('status')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('status-other-description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('deployment-model')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('deployment-model-other-description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('service-model', 'service-models')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('service-model-other-description', 'service-model-descriptions')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('leveraged-authorizations', 'ssp-leveraged-authorizations')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('authorization-boundary', 'ssp-authorization-boundary')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('network-architecture', 'ssp-network-architecture')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('data-flow', 'ssp-data-flow')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('users', 'ssp-users')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "system-id" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--system-characteristics ssp-system-characteristics-->
   <!--*[@key='system-characteristics']/*[@key='system-id'] | *[@key='ssp-system-characteristics']/*[@key='system-id'] | *[@key='ssp-system-characteristics']/*/*[@key='system-id'] -->
   <!--*[@key='system-id']-->
   <xsl:template match="*[@key='system-characteristics']/*[@key='system-id'] | *[@key='ssp-system-characteristics']/*[@key='system-id'] | *[@key='ssp-system-characteristics']/*/*[@key='system-id'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="system-id" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "system-name" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--system-characteristics ssp-system-characteristics-->
   <!--*[@key='system-characteristics']/*[@key='system-name'] | *[@key='ssp-system-characteristics']/*[@key='system-name'] | *[@key='ssp-system-characteristics']/*/*[@key='system-name'] -->
   <!--*[@key='system-name']-->
   <xsl:template match="*[@key='system-characteristics']/*[@key='system-name'] | *[@key='ssp-system-characteristics']/*[@key='system-name'] | *[@key='ssp-system-characteristics']/*/*[@key='system-name'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="system-name" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "system-name-short" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--system-characteristics ssp-system-characteristics-->
   <!--*[@key='system-characteristics']/*[@key='system-name-short'] | *[@key='ssp-system-characteristics']/*[@key='system-name-short'] | *[@key='ssp-system-characteristics']/*/*[@key='system-name-short'] -->
   <!--*[@key='system-name-short']-->
   <xsl:template match="*[@key='system-characteristics']/*[@key='system-name-short'] | *[@key='ssp-system-characteristics']/*[@key='system-name-short'] | *[@key='ssp-system-characteristics']/*/*[@key='system-name-short'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="system-name-short" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "description" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='description']" priority="4" mode="json2xml">
      <xsl:element name="description" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key='prose']"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "security-sensitivity-level" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--system-characteristics ssp-system-characteristics-->
   <!--*[@key='system-characteristics']/*[@key='security-sensitivity-level'] | *[@key='ssp-system-characteristics']/*[@key='security-sensitivity-level'] | *[@key='ssp-system-characteristics']/*/*[@key='security-sensitivity-level'] -->
   <!--*[@key='security-sensitivity-level']-->
   <xsl:template match="*[@key='system-characteristics']/*[@key='security-sensitivity-level'] | *[@key='ssp-system-characteristics']/*[@key='security-sensitivity-level'] | *[@key='ssp-system-characteristics']/*/*[@key='security-sensitivity-level'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="security-sensitivity-level" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "system-information" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='system-information'] | *[@key='ssp-system-information']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="system-information" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('information-type', 'ssp-information-type')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('designations', 'ssp-designations')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-system-information']/*"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="system-information" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('information-type', 'ssp-information-type')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('designations', 'ssp-designations')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "designations" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='designations'] | *[@key='ssp-designations']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="designations" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('designation', 'ssp-designation')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-designations']/*" priority="3" mode="json2xml">
      <xsl:element name="designations" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('designation', 'ssp-designation')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "designation" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='designation'] | *[@key='ssp-designation']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="designation" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('declaration')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('qualifiers', 'ssp-qualifiers')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-designation']/*" priority="3" mode="json2xml">
      <xsl:element name="designation" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('declaration')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('qualifiers', 'ssp-qualifiers')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "declaration" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--designation ssp-designation-->
   <!--*[@key='designation']/*[@key='declaration'] | *[@key='ssp-designation']/*[@key='declaration'] | *[@key='ssp-designation']/*/*[@key='declaration'] -->
   <!--*[@key='declaration']-->
   <xsl:template match="*[@key='designation']/*[@key='declaration'] | *[@key='ssp-designation']/*[@key='declaration'] | *[@key='ssp-designation']/*/*[@key='declaration'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="declaration" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "qualifiers" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='qualifiers'] | *[@key='ssp-qualifiers']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="qualifiers" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('qualifier', 'ssp-qualifiers')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-qualifiers']/*" priority="3" mode="json2xml">
      <xsl:element name="qualifiers" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('qualifier', 'ssp-qualifiers')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "qualifier" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='qualifier'] | *[@key='ssp-qualifiers']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="qualifier" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('qual-question')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('qual-response')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('qual-notes')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-qualifiers']/*" priority="3" mode="json2xml">
      <xsl:element name="qualifier" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('qual-question')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('qual-response')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('qual-notes')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "qual-question" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--qualifier ssp-qualifiers-->
   <!--*[@key='qualifier']/*[@key='qual-question'] | *[@key='ssp-qualifiers']/*[@key='qual-question'] | *[@key='ssp-qualifiers']/*/*[@key='qual-question'] -->
   <!--*[@key='qual-question']-->
   <xsl:template match="*[@key='qualifier']/*[@key='qual-question'] | *[@key='ssp-qualifiers']/*[@key='qual-question'] | *[@key='ssp-qualifiers']/*/*[@key='qual-question'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="qual-question" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "qual-response" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--qualifier ssp-qualifiers-->
   <!--*[@key='qualifier']/*[@key='qual-response'] | *[@key='ssp-qualifiers']/*[@key='qual-response'] | *[@key='ssp-qualifiers']/*/*[@key='qual-response'] -->
   <!--*[@key='qual-response']-->
   <xsl:template match="*[@key='qualifier']/*[@key='qual-response'] | *[@key='ssp-qualifiers']/*[@key='qual-response'] | *[@key='ssp-qualifiers']/*/*[@key='qual-response'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="qual-response" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "qual-notes" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--qualifier ssp-qualifiers-->
   <!--*[@key='qualifier']/*[@key='qual-notes'] | *[@key='ssp-qualifiers']/*[@key='qual-notes'] | *[@key='ssp-qualifiers']/*/*[@key='qual-notes'] -->
   <!--*[@key='qual-notes']-->
   <xsl:template match="*[@key='qualifier']/*[@key='qual-notes'] | *[@key='ssp-qualifiers']/*[@key='qual-notes'] | *[@key='ssp-qualifiers']/*/*[@key='qual-notes'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="qual-notes" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "information-type" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='information-type'] | *[@key='ssp-information-type']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="information-type" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('confidentiality-impact', 'ssp-confidentiality-impact')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('integrity-impact', 'ssp-integrity-impact')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('availability-impact', 'ssp-availability-impact')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-information-type']/*"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="information-type" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('confidentiality-impact', 'ssp-confidentiality-impact')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('integrity-impact', 'ssp-integrity-impact')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('availability-impact', 'ssp-availability-impact')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "confidentiality-impact" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='confidentiality-impact'] | *[@key='ssp-confidentiality-impact']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="confidentiality-impact" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('base')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('selected')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('adjustment-justification')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-confidentiality-impact']/*"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="confidentiality-impact" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('base')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('selected')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('adjustment-justification')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "integrity-impact" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='integrity-impact'] | *[@key='ssp-integrity-impact']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="integrity-impact" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('base')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('selected')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('adjustment-justification')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-integrity-impact']/*"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="integrity-impact" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('base')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('selected')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('adjustment-justification')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "availability-impact" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='availability-impact'] | *[@key='ssp-availability-impact']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="availability-impact" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('base')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('selected')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('adjustment-justification')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-availability-impact']/*"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="availability-impact" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('base')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('selected')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('adjustment-justification')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "base" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--confidentiality-impact ssp-confidentiality-impact integrity-impact ssp-integrity-impact availability-impact ssp-availability-impact-->
   <!--*[@key='confidentiality-impact']/*[@key='base'] | *[@key='integrity-impact']/*[@key='base'] | *[@key='availability-impact']/*[@key='base'] | *[@key='ssp-confidentiality-impact']/*[@key='base'] | *[@key='ssp-confidentiality-impact']/*/*[@key='base']  | *[@key='ssp-integrity-impact']/*[@key='base'] | *[@key='ssp-integrity-impact']/*/*[@key='base']  | *[@key='ssp-availability-impact']/*[@key='base'] | *[@key='ssp-availability-impact']/*/*[@key='base'] -->
   <!--*[@key='base']-->
   <xsl:template match="*[@key='confidentiality-impact']/*[@key='base'] | *[@key='integrity-impact']/*[@key='base'] | *[@key='availability-impact']/*[@key='base'] | *[@key='ssp-confidentiality-impact']/*[@key='base'] | *[@key='ssp-confidentiality-impact']/*/*[@key='base']  | *[@key='ssp-integrity-impact']/*[@key='base'] | *[@key='ssp-integrity-impact']/*/*[@key='base']  | *[@key='ssp-availability-impact']/*[@key='base'] | *[@key='ssp-availability-impact']/*/*[@key='base'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="base" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "selected" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--confidentiality-impact ssp-confidentiality-impact integrity-impact ssp-integrity-impact availability-impact ssp-availability-impact-->
   <!--*[@key='confidentiality-impact']/*[@key='selected'] | *[@key='integrity-impact']/*[@key='selected'] | *[@key='availability-impact']/*[@key='selected'] | *[@key='ssp-confidentiality-impact']/*[@key='selected'] | *[@key='ssp-confidentiality-impact']/*/*[@key='selected']  | *[@key='ssp-integrity-impact']/*[@key='selected'] | *[@key='ssp-integrity-impact']/*/*[@key='selected']  | *[@key='ssp-availability-impact']/*[@key='selected'] | *[@key='ssp-availability-impact']/*/*[@key='selected'] -->
   <!--*[@key='selected']-->
   <xsl:template match="*[@key='confidentiality-impact']/*[@key='selected'] | *[@key='integrity-impact']/*[@key='selected'] | *[@key='availability-impact']/*[@key='selected'] | *[@key='ssp-confidentiality-impact']/*[@key='selected'] | *[@key='ssp-confidentiality-impact']/*/*[@key='selected']  | *[@key='ssp-integrity-impact']/*[@key='selected'] | *[@key='ssp-integrity-impact']/*/*[@key='selected']  | *[@key='ssp-availability-impact']/*[@key='selected'] | *[@key='ssp-availability-impact']/*/*[@key='selected'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="selected" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "adjustment-justification" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--confidentiality-impact ssp-confidentiality-impact integrity-impact ssp-integrity-impact availability-impact ssp-availability-impact-->
   <!--*[@key='confidentiality-impact']/*[@key='adjustment-justification'] | *[@key='integrity-impact']/*[@key='adjustment-justification'] | *[@key='availability-impact']/*[@key='adjustment-justification'] | *[@key='ssp-confidentiality-impact']/*[@key='adjustment-justification'] | *[@key='ssp-confidentiality-impact']/*/*[@key='adjustment-justification']  | *[@key='ssp-integrity-impact']/*[@key='adjustment-justification'] | *[@key='ssp-integrity-impact']/*/*[@key='adjustment-justification']  | *[@key='ssp-availability-impact']/*[@key='adjustment-justification'] | *[@key='ssp-availability-impact']/*/*[@key='adjustment-justification'] -->
   <!--*[@key='adjustment-justification']-->
   <xsl:template match="*[@key='confidentiality-impact']/*[@key='adjustment-justification'] | *[@key='integrity-impact']/*[@key='adjustment-justification'] | *[@key='availability-impact']/*[@key='adjustment-justification'] | *[@key='ssp-confidentiality-impact']/*[@key='adjustment-justification'] | *[@key='ssp-confidentiality-impact']/*/*[@key='adjustment-justification']  | *[@key='ssp-integrity-impact']/*[@key='adjustment-justification'] | *[@key='ssp-integrity-impact']/*/*[@key='adjustment-justification']  | *[@key='ssp-availability-impact']/*[@key='adjustment-justification'] | *[@key='ssp-availability-impact']/*/*[@key='adjustment-justification'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="adjustment-justification" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "security-impact-level" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='security-impact-level'] | *[@key='ssp-security-impact-level']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="security-impact-level" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('security-objective-confidentiality')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('security-objective-integrity')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('security-objective-availability')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-security-impact-level']/*"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="security-impact-level" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('security-objective-confidentiality')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('security-objective-integrity')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('security-objective-availability')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "security-objective-confidentiality" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--security-impact-level ssp-security-impact-level-->
   <!--*[@key='security-impact-level']/*[@key='security-objective-confidentiality'] | *[@key='ssp-security-impact-level']/*[@key='security-objective-confidentiality'] | *[@key='ssp-security-impact-level']/*/*[@key='security-objective-confidentiality'] -->
   <!--*[@key='security-objective-confidentiality']-->
   <xsl:template match="*[@key='security-impact-level']/*[@key='security-objective-confidentiality'] | *[@key='ssp-security-impact-level']/*[@key='security-objective-confidentiality'] | *[@key='ssp-security-impact-level']/*/*[@key='security-objective-confidentiality'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="security-objective-confidentiality"
                   namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "security-objective-integrity" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--security-impact-level ssp-security-impact-level-->
   <!--*[@key='security-impact-level']/*[@key='security-objective-integrity'] | *[@key='ssp-security-impact-level']/*[@key='security-objective-integrity'] | *[@key='ssp-security-impact-level']/*/*[@key='security-objective-integrity'] -->
   <!--*[@key='security-objective-integrity']-->
   <xsl:template match="*[@key='security-impact-level']/*[@key='security-objective-integrity'] | *[@key='ssp-security-impact-level']/*[@key='security-objective-integrity'] | *[@key='ssp-security-impact-level']/*/*[@key='security-objective-integrity'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="security-objective-integrity"
                   namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "security-objective-availability" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--security-impact-level ssp-security-impact-level-->
   <!--*[@key='security-impact-level']/*[@key='security-objective-availability'] | *[@key='ssp-security-impact-level']/*[@key='security-objective-availability'] | *[@key='ssp-security-impact-level']/*/*[@key='security-objective-availability'] -->
   <!--*[@key='security-objective-availability']-->
   <xsl:template match="*[@key='security-impact-level']/*[@key='security-objective-availability'] | *[@key='ssp-security-impact-level']/*[@key='security-objective-availability'] | *[@key='ssp-security-impact-level']/*/*[@key='security-objective-availability'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="security-objective-availability"
                   namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "security-eauth" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='security-eauth'] | *[@key='ssp-security-eauth']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="security-eauth" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('security-auth-ial')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('security-auth-aal')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('security-auth-fal')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('security-eauth-level')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-security-eauth']/*" priority="3" mode="json2xml">
      <xsl:element name="security-eauth" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('security-auth-ial')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('security-auth-aal')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('security-auth-fal')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('security-eauth-level')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "security-auth-ial" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--security-eauth ssp-security-eauth-->
   <!--*[@key='security-eauth']/*[@key='security-auth-ial'] | *[@key='ssp-security-eauth']/*[@key='security-auth-ial'] | *[@key='ssp-security-eauth']/*/*[@key='security-auth-ial'] -->
   <!--*[@key='security-auth-ial']-->
   <xsl:template match="*[@key='security-eauth']/*[@key='security-auth-ial'] | *[@key='ssp-security-eauth']/*[@key='security-auth-ial'] | *[@key='ssp-security-eauth']/*/*[@key='security-auth-ial'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="security-auth-ial" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "security-auth-aal" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--security-eauth ssp-security-eauth-->
   <!--*[@key='security-eauth']/*[@key='security-auth-aal'] | *[@key='ssp-security-eauth']/*[@key='security-auth-aal'] | *[@key='ssp-security-eauth']/*/*[@key='security-auth-aal'] -->
   <!--*[@key='security-auth-aal']-->
   <xsl:template match="*[@key='security-eauth']/*[@key='security-auth-aal'] | *[@key='ssp-security-eauth']/*[@key='security-auth-aal'] | *[@key='ssp-security-eauth']/*/*[@key='security-auth-aal'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="security-auth-aal" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "security-auth-fal" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--security-eauth ssp-security-eauth-->
   <!--*[@key='security-eauth']/*[@key='security-auth-fal'] | *[@key='ssp-security-eauth']/*[@key='security-auth-fal'] | *[@key='ssp-security-eauth']/*/*[@key='security-auth-fal'] -->
   <!--*[@key='security-auth-fal']-->
   <xsl:template match="*[@key='security-eauth']/*[@key='security-auth-fal'] | *[@key='ssp-security-eauth']/*[@key='security-auth-fal'] | *[@key='ssp-security-eauth']/*/*[@key='security-auth-fal'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="security-auth-fal" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "security-eauth-level" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--security-eauth ssp-security-eauth-->
   <!--*[@key='security-eauth']/*[@key='security-eauth-level'] | *[@key='ssp-security-eauth']/*[@key='security-eauth-level'] | *[@key='ssp-security-eauth']/*/*[@key='security-eauth-level'] -->
   <!--*[@key='security-eauth-level']-->
   <xsl:template match="*[@key='security-eauth']/*[@key='security-eauth-level'] | *[@key='ssp-security-eauth']/*[@key='security-eauth-level'] | *[@key='ssp-security-eauth']/*/*[@key='security-eauth-level'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="security-eauth-level" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "status" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--system-characteristics ssp-system-characteristics-->
   <!--*[@key='system-characteristics']/*[@key='status'] | *[@key='ssp-system-characteristics']/*[@key='status'] | *[@key='ssp-system-characteristics']/*/*[@key='status'] -->
   <!--*[@key='status']-->
   <xsl:template match="*[@key='system-characteristics']/*[@key='status'] | *[@key='ssp-system-characteristics']/*[@key='status'] | *[@key='ssp-system-characteristics']/*/*[@key='status'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="status" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "status-other-description" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--system-characteristics ssp-system-characteristics-->
   <!--*[@key='system-characteristics']/*[@key='status-other-description'] | *[@key='ssp-system-characteristics']/*[@key='status-other-description'] | *[@key='ssp-system-characteristics']/*/*[@key='status-other-description'] -->
   <!--*[@key='status-other-description']-->
   <xsl:template match="*[@key='system-characteristics']/*[@key='status-other-description'] | *[@key='ssp-system-characteristics']/*[@key='status-other-description'] | *[@key='ssp-system-characteristics']/*/*[@key='status-other-description'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="status-other-description" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "deployment-model" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--system-characteristics ssp-system-characteristics-->
   <!--*[@key='system-characteristics']/*[@key='deployment-model'] | *[@key='ssp-system-characteristics']/*[@key='deployment-model'] | *[@key='ssp-system-characteristics']/*/*[@key='deployment-model'] -->
   <!--*[@key='deployment-model']-->
   <xsl:template match="*[@key='system-characteristics']/*[@key='deployment-model'] | *[@key='ssp-system-characteristics']/*[@key='deployment-model'] | *[@key='ssp-system-characteristics']/*/*[@key='deployment-model'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="deployment-model" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "deployment-model-other-description" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--system-characteristics ssp-system-characteristics-->
   <!--*[@key='system-characteristics']/*[@key='deployment-model-other-description'] | *[@key='ssp-system-characteristics']/*[@key='deployment-model-other-description'] | *[@key='ssp-system-characteristics']/*/*[@key='deployment-model-other-description'] -->
   <!--*[@key='deployment-model-other-description']-->
   <xsl:template match="*[@key='system-characteristics']/*[@key='deployment-model-other-description'] | *[@key='ssp-system-characteristics']/*[@key='deployment-model-other-description'] | *[@key='ssp-system-characteristics']/*/*[@key='deployment-model-other-description'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="deployment-model-other-description"
                   namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "service-model" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--system-characteristics ssp-system-characteristics-->
   <!--*[@key='system-characteristics']/*[@key='service-model'] | *[@key='service-models'] | array[@key='service-models']/* | *[@key='ssp-system-characteristics']/*[@key='service-model'] | *[@key='service-models'] | array[@key='service-models']/* | *[@key='ssp-system-characteristics']/*/*[@key='service-model'] | *[@key='service-models'] | array[@key='service-models']/* -->
   <!--*[@key='service-model'] | *[@key='service-models'] | array[@key='service-models']/*-->
   <xsl:template match="*[@key='system-characteristics']/*[@key='service-model'] | *[@key='service-models'] | array[@key='service-models']/* | *[@key='ssp-system-characteristics']/*[@key='service-model'] | *[@key='service-models'] | array[@key='service-models']/* | *[@key='ssp-system-characteristics']/*/*[@key='service-model'] | *[@key='service-models'] | array[@key='service-models']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="service-model" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='service-models'][array/@key='STRVALUE'] |  array[@key='service-models']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="service-models">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='service-models']/array[@key='STRVALUE']/string |  array[@key='service-models']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling field "service-model-other-description" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--system-characteristics ssp-system-characteristics-->
   <!--*[@key='system-characteristics']/*[@key='service-model-other-description'] | *[@key='service-model-descriptions'] | array[@key='service-model-descriptions']/* | *[@key='ssp-system-characteristics']/*[@key='service-model-other-description'] | *[@key='service-model-descriptions'] | array[@key='service-model-descriptions']/* | *[@key='ssp-system-characteristics']/*/*[@key='service-model-other-description'] | *[@key='service-model-descriptions'] | array[@key='service-model-descriptions']/* -->
   <!--*[@key='service-model-other-description'] | *[@key='service-model-descriptions'] | array[@key='service-model-descriptions']/*-->
   <xsl:template match="*[@key='system-characteristics']/*[@key='service-model-other-description'] | *[@key='service-model-descriptions'] | array[@key='service-model-descriptions']/* | *[@key='ssp-system-characteristics']/*[@key='service-model-other-description'] | *[@key='service-model-descriptions'] | array[@key='service-model-descriptions']/* | *[@key='ssp-system-characteristics']/*/*[@key='service-model-other-description'] | *[@key='service-model-descriptions'] | array[@key='service-model-descriptions']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="service-model-other-description"
                   namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='service-model-descriptions'][array/@key='STRVALUE'] |  array[@key='service-model-descriptions']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions"
                key="service-model-descriptions">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='service-model-descriptions']/array[@key='STRVALUE']/string |  array[@key='service-model-descriptions']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling assembly "leveraged-authorizations" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='leveraged-authorizations'] | *[@key='ssp-leveraged-authorizations']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="leveraged-authorizations" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('leveraged-authorization', 'ssp-leveraged-authorization')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-leveraged-authorizations']/*"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="leveraged-authorizations" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('leveraged-authorization', 'ssp-leveraged-authorization')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "leveraged-authorization" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='leveraged-authorization'] | *[@key='ssp-leveraged-authorization']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="leveraged-authorization" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('leveraged-authorization-name')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('leveraged-authorization-service-provider')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('leveraged-authorization-date-granted')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-leveraged-authorization']/*"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="leveraged-authorization" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('leveraged-authorization-name')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('leveraged-authorization-service-provider')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('leveraged-authorization-date-granted')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "leveraged-authorization-name" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--leveraged-authorization ssp-leveraged-authorization-->
   <!--*[@key='leveraged-authorization']/*[@key='leveraged-authorization-name'] | *[@key='ssp-leveraged-authorization']/*[@key='leveraged-authorization-name'] | *[@key='ssp-leveraged-authorization']/*/*[@key='leveraged-authorization-name'] -->
   <!--*[@key='leveraged-authorization-name']-->
   <xsl:template match="*[@key='leveraged-authorization']/*[@key='leveraged-authorization-name'] | *[@key='ssp-leveraged-authorization']/*[@key='leveraged-authorization-name'] | *[@key='ssp-leveraged-authorization']/*/*[@key='leveraged-authorization-name'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="leveraged-authorization-name"
                   namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "leveraged-authorization-service-provider" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--leveraged-authorization ssp-leveraged-authorization-->
   <!--*[@key='leveraged-authorization']/*[@key='leveraged-authorization-service-provider'] | *[@key='ssp-leveraged-authorization']/*[@key='leveraged-authorization-service-provider'] | *[@key='ssp-leveraged-authorization']/*/*[@key='leveraged-authorization-service-provider'] -->
   <!--*[@key='leveraged-authorization-service-provider']-->
   <xsl:template match="*[@key='leveraged-authorization']/*[@key='leveraged-authorization-service-provider'] | *[@key='ssp-leveraged-authorization']/*[@key='leveraged-authorization-service-provider'] | *[@key='ssp-leveraged-authorization']/*/*[@key='leveraged-authorization-service-provider'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="leveraged-authorization-service-provider"
                   namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "leveraged-authorization-date-granted" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--leveraged-authorization ssp-leveraged-authorization-->
   <!--*[@key='leveraged-authorization']/*[@key='leveraged-authorization-date-granted'] | *[@key='ssp-leveraged-authorization']/*[@key='leveraged-authorization-date-granted'] | *[@key='ssp-leveraged-authorization']/*/*[@key='leveraged-authorization-date-granted'] -->
   <!--*[@key='leveraged-authorization-date-granted']-->
   <xsl:template match="*[@key='leveraged-authorization']/*[@key='leveraged-authorization-date-granted'] | *[@key='ssp-leveraged-authorization']/*[@key='leveraged-authorization-date-granted'] | *[@key='ssp-leveraged-authorization']/*/*[@key='leveraged-authorization-date-granted'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="leveraged-authorization-date-granted"
                   namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "authorization-boundary" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='authorization-boundary'] | *[@key='ssp-authorization-boundary']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="authorization-boundary" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('boundary-diagram', 'ssp-boundary-diagram')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-authorization-boundary']/*"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="authorization-boundary" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('boundary-diagram', 'ssp-boundary-diagram')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "boundary-diagram" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='boundary-diagram'] | *[@key='ssp-boundary-diagram']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="boundary-diagram" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('boundary-description')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-boundary-diagram']/*"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="boundary-diagram" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('boundary-description')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "boundary-description" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='boundary-description']" priority="4" mode="json2xml">
      <xsl:element name="boundary-description" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key='prose']"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "network-architecture" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='network-architecture'] | *[@key='ssp-network-architecture']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="network-architecture" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('network-diagram', 'ssp-network-boundary')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-network-architecture']/*"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="network-architecture" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('network-diagram', 'ssp-network-boundary')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "network-diagram" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='network-diagram'] | *[@key='ssp-network-boundary']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="network-diagram" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('network-description')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-network-boundary']/*"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="network-diagram" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('network-description')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "network-description" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='network-description']" priority="4" mode="json2xml">
      <xsl:element name="network-description" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key='prose']"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "data-flow" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='data-flow'] | *[@key='ssp-data-flow']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="data-flow" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('data-flow-diagram', 'ssp-data-flow-diagram')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-data-flow']/*" priority="3" mode="json2xml">
      <xsl:element name="data-flow" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('data-flow-diagram', 'ssp-data-flow-diagram')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "data-flow-diagram" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='data-flow-diagram'] | *[@key='ssp-data-flow-diagram']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="data-flow-diagram" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('data-flow-description')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-data-flow-diagram']/*"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="data-flow-diagram" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('data-flow-description')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "data-flow-description" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='data-flow-description']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="data-flow-description" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key='prose']"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "users" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='users'] | *[@key='ssp-users']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="users" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('role', 'roles')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('statistics', 'ssp-statistics')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-users']/*" priority="3" mode="json2xml">
      <xsl:element name="users" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('role', 'roles')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('statistics', 'ssp-statistics')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "role" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='role'] | *[@key='roles']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="role" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('short-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('desc')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('privilege', 'privileges')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('responsibility', 'responsibilities')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='roles']/*" priority="3" mode="json2xml">
      <xsl:element name="role" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('short-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('desc')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('privilege', 'privileges')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('responsibility', 'responsibilities')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "privilege" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--role roles-->
   <!--*[@key='role']/*[@key='privilege'] | *[@key='privileges'] | array[@key='privileges']/* | *[@key='roles']/*[@key='privilege'] | *[@key='privileges'] | array[@key='privileges']/* | *[@key='roles']/*/*[@key='privilege'] | *[@key='privileges'] | array[@key='privileges']/* -->
   <!--*[@key='privilege'] | *[@key='privileges'] | array[@key='privileges']/*-->
   <xsl:template match="*[@key='role']/*[@key='privilege'] | *[@key='privileges'] | array[@key='privileges']/* | *[@key='roles']/*[@key='privilege'] | *[@key='privileges'] | array[@key='privileges']/* | *[@key='roles']/*/*[@key='privilege'] | *[@key='privileges'] | array[@key='privileges']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="privilege" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='privileges'][array/@key='STRVALUE'] |  array[@key='privileges']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="privileges">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='privileges']/array[@key='STRVALUE']/string |  array[@key='privileges']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling field "responsibility" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--role roles-->
   <!--*[@key='role']/*[@key='responsibility'] | *[@key='responsibilities'] | array[@key='responsibilities']/* | *[@key='roles']/*[@key='responsibility'] | *[@key='responsibilities'] | array[@key='responsibilities']/* | *[@key='roles']/*/*[@key='responsibility'] | *[@key='responsibilities'] | array[@key='responsibilities']/* -->
   <!--*[@key='responsibility'] | *[@key='responsibilities'] | array[@key='responsibilities']/*-->
   <xsl:template match="*[@key='role']/*[@key='responsibility'] | *[@key='responsibilities'] | array[@key='responsibilities']/* | *[@key='roles']/*[@key='responsibility'] | *[@key='responsibilities'] | array[@key='responsibilities']/* | *[@key='roles']/*/*[@key='responsibility'] | *[@key='responsibilities'] | array[@key='responsibilities']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="responsibility" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='responsibilities'][array/@key='STRVALUE'] |  array[@key='responsibilities']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="responsibilities">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='responsibilities']/array[@key='STRVALUE']/string |  array[@key='responsibilities']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling assembly "statistics" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='statistics'] | *[@key='ssp-statistics']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="statistics" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('internal-user-total-current')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('internal-user-total-future')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('external-user-total-current')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('external-user-total-future')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-statistics']/*" priority="3" mode="json2xml">
      <xsl:element name="statistics" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('internal-user-total-current')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('internal-user-total-future')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('external-user-total-current')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('external-user-total-future')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "internal-user-total-current" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--statistics ssp-statistics-->
   <!--*[@key='statistics']/*[@key='internal-user-total-current'] | *[@key='ssp-statistics']/*[@key='internal-user-total-current'] | *[@key='ssp-statistics']/*/*[@key='internal-user-total-current'] -->
   <!--*[@key='internal-user-total-current']-->
   <xsl:template match="*[@key='statistics']/*[@key='internal-user-total-current'] | *[@key='ssp-statistics']/*[@key='internal-user-total-current'] | *[@key='ssp-statistics']/*/*[@key='internal-user-total-current'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="internal-user-total-current" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "internal-user-total-future" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--statistics ssp-statistics-->
   <!--*[@key='statistics']/*[@key='internal-user-total-future'] | *[@key='ssp-statistics']/*[@key='internal-user-total-future'] | *[@key='ssp-statistics']/*/*[@key='internal-user-total-future'] -->
   <!--*[@key='internal-user-total-future']-->
   <xsl:template match="*[@key='statistics']/*[@key='internal-user-total-future'] | *[@key='ssp-statistics']/*[@key='internal-user-total-future'] | *[@key='ssp-statistics']/*/*[@key='internal-user-total-future'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="internal-user-total-future" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "external-user-total-current" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--statistics ssp-statistics-->
   <!--*[@key='statistics']/*[@key='external-user-total-current'] | *[@key='ssp-statistics']/*[@key='external-user-total-current'] | *[@key='ssp-statistics']/*/*[@key='external-user-total-current'] -->
   <!--*[@key='external-user-total-current']-->
   <xsl:template match="*[@key='statistics']/*[@key='external-user-total-current'] | *[@key='ssp-statistics']/*[@key='external-user-total-current'] | *[@key='ssp-statistics']/*/*[@key='external-user-total-current'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="external-user-total-current" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "external-user-total-future" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--statistics ssp-statistics-->
   <!--*[@key='statistics']/*[@key='external-user-total-future'] | *[@key='ssp-statistics']/*[@key='external-user-total-future'] | *[@key='ssp-statistics']/*/*[@key='external-user-total-future'] -->
   <!--*[@key='external-user-total-future']-->
   <xsl:template match="*[@key='statistics']/*[@key='external-user-total-future'] | *[@key='ssp-statistics']/*[@key='external-user-total-future'] | *[@key='ssp-statistics']/*/*[@key='external-user-total-future'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="external-user-total-future" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "system-implementation" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='system-implementation'] | *[@key='ssp-system-implementation']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="system-implementation" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('ports-protocols-services', 'ssp-ports-protocols-services')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('interconnection', 'ssp-interconnection')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('component', 'components')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('system-inventory', 'ssp-system-inventory')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-system-implementation']/*"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="system-implementation" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('ports-protocols-services', 'ssp-ports-protocols-services')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('interconnection', 'ssp-interconnection')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('component', 'components')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('system-inventory', 'ssp-system-inventory')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "ports-protocols-services" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='ports-protocols-services'] | *[@key='ssp-ports-protocols-services']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="ports-protocols-services" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('service', 'ssp-service')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-ports-protocols-services']/*"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="ports-protocols-services" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('service', 'ssp-service')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "service" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='service'] | *[@key='ssp-service']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="service" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('protocol', 'ssp-protocol')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('purpose')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('used-by', 'component-users')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-service']/*" priority="3" mode="json2xml">
      <xsl:element name="service" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('protocol', 'ssp-protocol')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('purpose')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('used-by', 'component-users')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "protocol" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='protocol'] | *[@key='ssp-protocol']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="protocol" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('port-range', 'port-ranges')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-protocol']/*" priority="3" mode="json2xml">
      <xsl:element name="protocol" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('port-range', 'port-ranges')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "port-range" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--protocol ssp-protocol-->
   <!--*[@key='protocol']/*[@key='port-range'] | *[@key='port-ranges'] | array[@key='port-ranges']/* | *[@key='ssp-protocol']/*[@key='port-range'] | *[@key='port-ranges'] | array[@key='port-ranges']/* | *[@key='ssp-protocol']/*/*[@key='port-range'] | *[@key='port-ranges'] | array[@key='port-ranges']/* -->
   <!--*[@key='port-range'] | *[@key='port-ranges'] | array[@key='port-ranges']/*-->
   <xsl:template match="*[@key='protocol']/*[@key='port-range'] | *[@key='port-ranges'] | array[@key='port-ranges']/* | *[@key='ssp-protocol']/*[@key='port-range'] | *[@key='port-ranges'] | array[@key='port-ranges']/* | *[@key='ssp-protocol']/*/*[@key='port-range'] | *[@key='port-ranges'] | array[@key='port-ranges']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="port-range" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='port-ranges'][array/@key='STRVALUE'] |  array[@key='port-ranges']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="port-ranges">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='port-ranges']/array[@key='STRVALUE']/string |  array[@key='port-ranges']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling field "purpose" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--service ssp-service-->
   <!--*[@key='service']/*[@key='purpose'] | *[@key='ssp-service']/*[@key='purpose'] | *[@key='ssp-service']/*/*[@key='purpose'] -->
   <!--*[@key='purpose']-->
   <xsl:template match="*[@key='service']/*[@key='purpose'] | *[@key='ssp-service']/*[@key='purpose'] | *[@key='ssp-service']/*/*[@key='purpose'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="purpose" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:for-each select="string[@key='RICHTEXT'], self::string">
            <xsl:variable name="markup">
               <xsl:apply-templates mode="infer-inlines"/>
            </xsl:variable>
            <xsl:apply-templates mode="cast-ns" select="$markup"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "used-by" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--service ssp-service-->
   <!--*[@key='service']/*[@key='used-by'] | *[@key='component-users'] | array[@key='component-users']/* | *[@key='ssp-service']/*[@key='used-by'] | *[@key='component-users'] | array[@key='component-users']/* | *[@key='ssp-service']/*/*[@key='used-by'] | *[@key='component-users'] | array[@key='component-users']/* -->
   <!--*[@key='used-by'] | *[@key='component-users'] | array[@key='component-users']/*-->
   <xsl:template match="*[@key='service']/*[@key='used-by'] | *[@key='component-users'] | array[@key='component-users']/* | *[@key='ssp-service']/*[@key='used-by'] | *[@key='component-users'] | array[@key='component-users']/* | *[@key='ssp-service']/*/*[@key='used-by'] | *[@key='component-users'] | array[@key='component-users']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="used-by" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='component-users'][array/@key='STRVALUE'] |  array[@key='component-users']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="component-users">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='component-users']/array[@key='STRVALUE']/string |  array[@key='component-users']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling flag "interconnected" 000 -->
   <xsl:template match="*[@key='interconnected']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='system-implementation']/*[@key='interconnected'] | *[@key='ssp-system-implementation']/*[@key='interconnected'] | array[@key='ssp-system-implementation']/*/*[@key='interconnected']"
                 mode="as-attribute">
      <xsl:attribute name="interconnected">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling assembly "interconnection" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='interconnection'] | *[@key='ssp-interconnection']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="interconnection" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('external-system-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('external-system-org')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('isa-authorization', 'isa-authorizations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('isa-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('isa-date')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-interconnection']/*"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="interconnection" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('external-system-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('external-system-org')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('isa-authorization', 'isa-authorizations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('isa-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('isa-date')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "external-system-name" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--interconnection ssp-interconnection-->
   <!--*[@key='interconnection']/*[@key='external-system-name'] | *[@key='ssp-interconnection']/*[@key='external-system-name'] | *[@key='ssp-interconnection']/*/*[@key='external-system-name'] -->
   <!--*[@key='external-system-name']-->
   <xsl:template match="*[@key='interconnection']/*[@key='external-system-name'] | *[@key='ssp-interconnection']/*[@key='external-system-name'] | *[@key='ssp-interconnection']/*/*[@key='external-system-name'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="external-system-name" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "external-system-org" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--interconnection ssp-interconnection-->
   <!--*[@key='interconnection']/*[@key='external-system-org'] | *[@key='ssp-interconnection']/*[@key='external-system-org'] | *[@key='ssp-interconnection']/*/*[@key='external-system-org'] -->
   <!--*[@key='external-system-org']-->
   <xsl:template match="*[@key='interconnection']/*[@key='external-system-org'] | *[@key='ssp-interconnection']/*[@key='external-system-org'] | *[@key='ssp-interconnection']/*/*[@key='external-system-org'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="external-system-org" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "isa-authorization" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--interconnection ssp-interconnection-->
   <!--*[@key='interconnection']/*[@key='isa-authorization'] | *[@key='isa-authorizations'] | array[@key='isa-authorizations']/* | *[@key='ssp-interconnection']/*[@key='isa-authorization'] | *[@key='isa-authorizations'] | array[@key='isa-authorizations']/* | *[@key='ssp-interconnection']/*/*[@key='isa-authorization'] | *[@key='isa-authorizations'] | array[@key='isa-authorizations']/* -->
   <!--*[@key='isa-authorization'] | *[@key='isa-authorizations'] | array[@key='isa-authorizations']/*-->
   <xsl:template match="*[@key='interconnection']/*[@key='isa-authorization'] | *[@key='isa-authorizations'] | array[@key='isa-authorizations']/* | *[@key='ssp-interconnection']/*[@key='isa-authorization'] | *[@key='isa-authorizations'] | array[@key='isa-authorizations']/* | *[@key='ssp-interconnection']/*/*[@key='isa-authorization'] | *[@key='isa-authorizations'] | array[@key='isa-authorizations']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="isa-authorization" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='isa-authorizations'][array/@key='STRVALUE'] |  array[@key='isa-authorizations']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="isa-authorizations">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='isa-authorizations']/array[@key='STRVALUE']/string |  array[@key='isa-authorizations']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling field "isa-name" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--interconnection ssp-interconnection-->
   <!--*[@key='interconnection']/*[@key='isa-name'] | *[@key='ssp-interconnection']/*[@key='isa-name'] | *[@key='ssp-interconnection']/*/*[@key='isa-name'] -->
   <!--*[@key='isa-name']-->
   <xsl:template match="*[@key='interconnection']/*[@key='isa-name'] | *[@key='ssp-interconnection']/*[@key='isa-name'] | *[@key='ssp-interconnection']/*/*[@key='isa-name'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="isa-name" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "isa-date" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--interconnection ssp-interconnection-->
   <!--*[@key='interconnection']/*[@key='isa-date'] | *[@key='ssp-interconnection']/*[@key='isa-date'] | *[@key='ssp-interconnection']/*/*[@key='isa-date'] -->
   <!--*[@key='isa-date']-->
   <xsl:template match="*[@key='interconnection']/*[@key='isa-date'] | *[@key='ssp-interconnection']/*[@key='isa-date'] | *[@key='ssp-interconnection']/*/*[@key='isa-date'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="isa-date" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "component" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='component'] | *[@key='components']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="component" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('origin', 'ssp-origin')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('characteristics', 'ssp-characteristics')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('satisfaction', 'ssp-satisfaction')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('validation', 'validations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('provisioning', 'ssp-provisioning')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('subcomponent', 'subcomponents')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='components']/*" priority="3" mode="json2xml">
      <xsl:element name="component" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('origin', 'ssp-origin')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('characteristics', 'ssp-characteristics')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('satisfaction', 'ssp-satisfaction')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('validation', 'validations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('provisioning', 'ssp-provisioning')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('subcomponent', 'subcomponents')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "origin" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='origin'] | *[@key='ssp-origin']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="origin" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('organization')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('version')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('release-date')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('model')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('part', 'ssp-part')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-origin']/*" priority="3" mode="json2xml">
      <xsl:element name="origin" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('organization')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('version')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('release-date')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('model')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('part', 'ssp-part')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling flag "id" 000 -->
   <xsl:template match="*[@key='id']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='prop']/*[@key='id'] | *[@key='properties']/*[@key='id'] | array[@key='properties']/*/*[@key='id'] | *[@key='party']/*[@key='id'] | *[@key='parties']/*[@key='id'] | array[@key='parties']/*/*[@key='id'] | *[@key='resource']/*[@key='id'] | *[@key='resources']/*[@key='id'] | array[@key='resources']/*/*[@key='id'] | *[@key='system-security-plan']/*[@key='id'] | *[@key='ssp']/*[@key='id'] | array[@key='ssp']/*/*[@key='id'] | *[@key='designation']/*[@key='id'] | *[@key='ssp-designation']/*[@key='id'] | array[@key='ssp-designation']/*/*[@key='id'] | *[@key='qualifier']/*[@key='id'] | *[@key='ssp-qualifiers']/*[@key='id'] | array[@key='ssp-qualifiers']/*/*[@key='id'] | *[@key='information-type']/*[@key='id'] | *[@key='ssp-information-type']/*[@key='id'] | array[@key='ssp-information-type']/*/*[@key='id'] | *[@key='leveraged-authorization']/*[@key='id'] | *[@key='ssp-leveraged-authorization']/*[@key='id'] | array[@key='ssp-leveraged-authorization']/*/*[@key='id'] | *[@key='boundary-diagram']/*[@key='id'] | *[@key='ssp-boundary-diagram']/*[@key='id'] | array[@key='ssp-boundary-diagram']/*/*[@key='id'] | *[@key='network-diagram']/*[@key='id'] | *[@key='ssp-network-boundary']/*[@key='id'] | array[@key='ssp-network-boundary']/*/*[@key='id'] | *[@key='data-flow-diagram']/*[@key='id'] | *[@key='ssp-data-flow-diagram']/*[@key='id'] | array[@key='ssp-data-flow-diagram']/*/*[@key='id'] | *[@key='role']/*[@key='id'] | *[@key='roles']/*[@key='id'] | array[@key='roles']/*/*[@key='id'] | *[@key='service']/*[@key='id'] | *[@key='ssp-service']/*[@key='id'] | array[@key='ssp-service']/*/*[@key='id'] | *[@key='interconnection']/*[@key='id'] | *[@key='ssp-interconnection']/*[@key='id'] | array[@key='ssp-interconnection']/*/*[@key='id'] | *[@key='component']/*[@key='id'] | *[@key='components']/*[@key='id'] | array[@key='components']/*/*[@key='id'] | *[@key='origin']/*[@key='id'] | *[@key='ssp-origin']/*[@key='id'] | array[@key='ssp-origin']/*/*[@key='id'] | *[@key='vendor']/*[@key='id'] | *[@key='vendors']/*[@key='id'] | array[@key='vendors']/*/*[@key='id'] | *[@key='satisfaction']/*[@key='id'] | *[@key='ssp-satisfaction']/*[@key='id'] | array[@key='ssp-satisfaction']/*/*[@key='id'] | *[@key='inventory-item']/*[@key='id'] | *[@key='inventory-items']/*[@key='id'] | array[@key='inventory-items']/*/*[@key='id'] | *[@key='references']/*[@key='id'] | *[@key='ref']/*[@key='id'] | *[@key='refs']/*[@key='id'] | array[@key='refs']/*/*[@key='id'] | *[@key='citation']/*[@key='id'] | *[@key='citations']/*[@key='id'] | array[@key='citations']/*/*[@key='id'] | *[@key='attachment']/*[@key='id']"
                 mode="as-attribute">
      <xsl:attribute name="id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling field "vendor" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--host-item ssp-host-item software-item ssp-software-item-->
   <!--*[@key='host-item']/*[@key='vendor'] | *[@key='vendors'] | array[@key='vendors']/* | *[@key='software-item']/*[@key='vendor'] | *[@key='vendors'] | array[@key='vendors']/* | *[@key='ssp-host-item']/*[@key='vendor'] | *[@key='vendors'] | array[@key='vendors']/* | *[@key='ssp-host-item']/*/*[@key='vendor'] | *[@key='vendors'] | array[@key='vendors']/*  | *[@key='ssp-software-item']/*[@key='vendor'] | *[@key='vendors'] | array[@key='vendors']/* | *[@key='ssp-software-item']/*/*[@key='vendor'] | *[@key='vendors'] | array[@key='vendors']/* -->
   <!--*[@key='vendor'] | *[@key='vendors'] | array[@key='vendors']/*-->
   <xsl:template match="*[@key='host-item']/*[@key='vendor'] | *[@key='vendors'] | array[@key='vendors']/* | *[@key='software-item']/*[@key='vendor'] | *[@key='vendors'] | array[@key='vendors']/* | *[@key='ssp-host-item']/*[@key='vendor'] | *[@key='vendors'] | array[@key='vendors']/* | *[@key='ssp-host-item']/*/*[@key='vendor'] | *[@key='vendors'] | array[@key='vendors']/*  | *[@key='ssp-software-item']/*[@key='vendor'] | *[@key='vendors'] | array[@key='vendors']/* | *[@key='ssp-software-item']/*/*[@key='vendor'] | *[@key='vendors'] | array[@key='vendors']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="vendor" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='vendors'][array/@key='STRVALUE'] |  array[@key='vendors']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="vendors">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='vendors']/array[@key='STRVALUE']/string |  array[@key='vendors']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling field "release-date" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--origin ssp-origin-->
   <!--*[@key='origin']/*[@key='release-date'] | *[@key='ssp-origin']/*[@key='release-date'] | *[@key='ssp-origin']/*/*[@key='release-date'] -->
   <!--*[@key='release-date']-->
   <xsl:template match="*[@key='origin']/*[@key='release-date'] | *[@key='ssp-origin']/*[@key='release-date'] | *[@key='ssp-origin']/*/*[@key='release-date'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="release-date" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "model" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--origin ssp-origin-->
   <!--*[@key='origin']/*[@key='model'] | *[@key='ssp-origin']/*[@key='model'] | *[@key='ssp-origin']/*/*[@key='model'] -->
   <!--*[@key='model']-->
   <xsl:template match="*[@key='origin']/*[@key='model'] | *[@key='ssp-origin']/*[@key='model'] | *[@key='ssp-origin']/*/*[@key='model'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="model" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "part" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='part'] | *[@key='ssp-part']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="part" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('phone', 'telephone-numbers')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('email', 'email-addresses')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-part']/*" priority="3" mode="json2xml">
      <xsl:element name="part" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('phone', 'telephone-numbers')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('email', 'email-addresses')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "characteristics" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='characteristics'] | *[@key='ssp-characteristics']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="characteristics" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('ip-address', 'ip-addresses')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('service', 'ssp-service')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('part', 'ssp-part')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-characteristics']/*"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="characteristics" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('ip-address', 'ip-addresses')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('service', 'ssp-service')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('part', 'ssp-part')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "ip-address" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--characteristics ssp-characteristics inventory-item inventory-items-->
   <!--*[@key='characteristics']/*[@key='ip-address'] | *[@key='ip-addresses'] | array[@key='ip-addresses']/* | *[@key='inventory-item']/*[@key='ip-address'] | *[@key='ip-addresses'] | array[@key='ip-addresses']/* | *[@key='ssp-characteristics']/*[@key='ip-address'] | *[@key='ip-addresses'] | array[@key='ip-addresses']/* | *[@key='ssp-characteristics']/*/*[@key='ip-address'] | *[@key='ip-addresses'] | array[@key='ip-addresses']/*  | *[@key='inventory-items']/*[@key='ip-address'] | *[@key='ip-addresses'] | array[@key='ip-addresses']/* | *[@key='inventory-items']/*/*[@key='ip-address'] | *[@key='ip-addresses'] | array[@key='ip-addresses']/* -->
   <!--*[@key='ip-address'] | *[@key='ip-addresses'] | array[@key='ip-addresses']/*-->
   <xsl:template match="*[@key='characteristics']/*[@key='ip-address'] | *[@key='ip-addresses'] | array[@key='ip-addresses']/* | *[@key='inventory-item']/*[@key='ip-address'] | *[@key='ip-addresses'] | array[@key='ip-addresses']/* | *[@key='ssp-characteristics']/*[@key='ip-address'] | *[@key='ip-addresses'] | array[@key='ip-addresses']/* | *[@key='ssp-characteristics']/*/*[@key='ip-address'] | *[@key='ip-addresses'] | array[@key='ip-addresses']/*  | *[@key='inventory-items']/*[@key='ip-address'] | *[@key='ip-addresses'] | array[@key='ip-addresses']/* | *[@key='inventory-items']/*/*[@key='ip-address'] | *[@key='ip-addresses'] | array[@key='ip-addresses']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="ip-address" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='ip-addresses'][array/@key='STRVALUE'] |  array[@key='ip-addresses']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="ip-addresses">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='ip-addresses']/array[@key='STRVALUE']/string |  array[@key='ip-addresses']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling assembly "satisfaction" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='satisfaction'] | *[@key='ssp-satisfaction']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="satisfaction" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key='prose']"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-satisfaction']/*" priority="3" mode="json2xml">
      <xsl:element name="satisfaction" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key='prose']"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "system-inventory" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='system-inventory'] | *[@key='ssp-system-inventory']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="system-inventory" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('inventory-item', 'inventory-items')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-system-inventory']/*"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="system-inventory" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('inventory-item', 'inventory-items')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "inventory-item" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='inventory-item'] | *[@key='inventory-items']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="inventory-item" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('ip-address', 'ip-addresses')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('dns-name', 'dns-names')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('host-item', 'ssp-host-item')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('software-item', 'ssp-software-item')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('comments')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('serial-no')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('network-id', 'network-ids')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('asset-owner', 'asset-owners')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('asset-administrator', 'asset-administrators')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='inventory-items']/*" priority="3" mode="json2xml">
      <xsl:element name="inventory-item" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('ip-address', 'ip-addresses')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('dns-name', 'dns-names')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('host-item', 'ssp-host-item')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('software-item', 'ssp-software-item')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('comments')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('serial-no')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('network-id', 'network-ids')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('asset-owner', 'asset-owners')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('asset-administrator', 'asset-administrators')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "dns-name" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--inventory-item inventory-items-->
   <!--*[@key='inventory-item']/*[@key='dns-name'] | *[@key='dns-names'] | array[@key='dns-names']/* | *[@key='inventory-items']/*[@key='dns-name'] | *[@key='dns-names'] | array[@key='dns-names']/* | *[@key='inventory-items']/*/*[@key='dns-name'] | *[@key='dns-names'] | array[@key='dns-names']/* -->
   <!--*[@key='dns-name'] | *[@key='dns-names'] | array[@key='dns-names']/*-->
   <xsl:template match="*[@key='inventory-item']/*[@key='dns-name'] | *[@key='dns-names'] | array[@key='dns-names']/* | *[@key='inventory-items']/*[@key='dns-name'] | *[@key='dns-names'] | array[@key='dns-names']/* | *[@key='inventory-items']/*/*[@key='dns-name'] | *[@key='dns-names'] | array[@key='dns-names']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="dns-name" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='dns-names'][array/@key='STRVALUE'] |  array[@key='dns-names']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="dns-names">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='dns-names']/array[@key='STRVALUE']/string |  array[@key='dns-names']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling assembly "host-item" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='host-item'] | *[@key='ssp-host-item']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="host-item" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('netbios-name', 'netbios-names')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('mac-address', 'mac-addresses')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('authenticated-scan', 'authenticated-scans')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('baseline-template', 'baseline-templates')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('os-name', 'os-names')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('os-version', 'os-versions')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('location', 'locations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('asset-type', 'asset-types')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('vendor', 'vendors')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('hardware-model', 'hardware-models')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('scanned', 'ssp-scanned')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-host-item']/*" priority="3" mode="json2xml">
      <xsl:element name="host-item" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('netbios-name', 'netbios-names')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('mac-address', 'mac-addresses')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('authenticated-scan', 'authenticated-scans')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('baseline-template', 'baseline-templates')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('os-name', 'os-names')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('os-version', 'os-versions')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('location', 'locations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('asset-type', 'asset-types')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('vendor', 'vendors')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('hardware-model', 'hardware-models')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('scanned', 'ssp-scanned')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "netbios-name" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--host-item ssp-host-item-->
   <!--*[@key='host-item']/*[@key='netbios-name'] | *[@key='netbios-names'] | array[@key='netbios-names']/* | *[@key='ssp-host-item']/*[@key='netbios-name'] | *[@key='netbios-names'] | array[@key='netbios-names']/* | *[@key='ssp-host-item']/*/*[@key='netbios-name'] | *[@key='netbios-names'] | array[@key='netbios-names']/* -->
   <!--*[@key='netbios-name'] | *[@key='netbios-names'] | array[@key='netbios-names']/*-->
   <xsl:template match="*[@key='host-item']/*[@key='netbios-name'] | *[@key='netbios-names'] | array[@key='netbios-names']/* | *[@key='ssp-host-item']/*[@key='netbios-name'] | *[@key='netbios-names'] | array[@key='netbios-names']/* | *[@key='ssp-host-item']/*/*[@key='netbios-name'] | *[@key='netbios-names'] | array[@key='netbios-names']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="netbios-name" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='netbios-names'][array/@key='STRVALUE'] |  array[@key='netbios-names']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="netbios-names">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='netbios-names']/array[@key='STRVALUE']/string |  array[@key='netbios-names']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling field "mac-address" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--host-item ssp-host-item-->
   <!--*[@key='host-item']/*[@key='mac-address'] | *[@key='mac-addresses'] | array[@key='mac-addresses']/* | *[@key='ssp-host-item']/*[@key='mac-address'] | *[@key='mac-addresses'] | array[@key='mac-addresses']/* | *[@key='ssp-host-item']/*/*[@key='mac-address'] | *[@key='mac-addresses'] | array[@key='mac-addresses']/* -->
   <!--*[@key='mac-address'] | *[@key='mac-addresses'] | array[@key='mac-addresses']/*-->
   <xsl:template match="*[@key='host-item']/*[@key='mac-address'] | *[@key='mac-addresses'] | array[@key='mac-addresses']/* | *[@key='ssp-host-item']/*[@key='mac-address'] | *[@key='mac-addresses'] | array[@key='mac-addresses']/* | *[@key='ssp-host-item']/*/*[@key='mac-address'] | *[@key='mac-addresses'] | array[@key='mac-addresses']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="mac-address" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='mac-addresses'][array/@key='STRVALUE'] |  array[@key='mac-addresses']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="mac-addresses">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='mac-addresses']/array[@key='STRVALUE']/string |  array[@key='mac-addresses']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling field "os-name" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--host-item ssp-host-item-->
   <!--*[@key='host-item']/*[@key='os-name'] | *[@key='os-names'] | array[@key='os-names']/* | *[@key='ssp-host-item']/*[@key='os-name'] | *[@key='os-names'] | array[@key='os-names']/* | *[@key='ssp-host-item']/*/*[@key='os-name'] | *[@key='os-names'] | array[@key='os-names']/* -->
   <!--*[@key='os-name'] | *[@key='os-names'] | array[@key='os-names']/*-->
   <xsl:template match="*[@key='host-item']/*[@key='os-name'] | *[@key='os-names'] | array[@key='os-names']/* | *[@key='ssp-host-item']/*[@key='os-name'] | *[@key='os-names'] | array[@key='os-names']/* | *[@key='ssp-host-item']/*/*[@key='os-name'] | *[@key='os-names'] | array[@key='os-names']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="os-name" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='os-names'][array/@key='STRVALUE'] |  array[@key='os-names']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="os-names">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='os-names']/array[@key='STRVALUE']/string |  array[@key='os-names']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling field "os-version" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--host-item ssp-host-item-->
   <!--*[@key='host-item']/*[@key='os-version'] | *[@key='os-versions'] | array[@key='os-versions']/* | *[@key='ssp-host-item']/*[@key='os-version'] | *[@key='os-versions'] | array[@key='os-versions']/* | *[@key='ssp-host-item']/*/*[@key='os-version'] | *[@key='os-versions'] | array[@key='os-versions']/* -->
   <!--*[@key='os-version'] | *[@key='os-versions'] | array[@key='os-versions']/*-->
   <xsl:template match="*[@key='host-item']/*[@key='os-version'] | *[@key='os-versions'] | array[@key='os-versions']/* | *[@key='ssp-host-item']/*[@key='os-version'] | *[@key='os-versions'] | array[@key='os-versions']/* | *[@key='ssp-host-item']/*/*[@key='os-version'] | *[@key='os-versions'] | array[@key='os-versions']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="os-version" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='os-versions'][array/@key='STRVALUE'] |  array[@key='os-versions']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="os-versions">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='os-versions']/array[@key='STRVALUE']/string |  array[@key='os-versions']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling field "location" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--host-item ssp-host-item-->
   <!--*[@key='host-item']/*[@key='location'] | *[@key='locations'] | array[@key='locations']/* | *[@key='ssp-host-item']/*[@key='location'] | *[@key='locations'] | array[@key='locations']/* | *[@key='ssp-host-item']/*/*[@key='location'] | *[@key='locations'] | array[@key='locations']/* -->
   <!--*[@key='location'] | *[@key='locations'] | array[@key='locations']/*-->
   <xsl:template match="*[@key='host-item']/*[@key='location'] | *[@key='locations'] | array[@key='locations']/* | *[@key='ssp-host-item']/*[@key='location'] | *[@key='locations'] | array[@key='locations']/* | *[@key='ssp-host-item']/*/*[@key='location'] | *[@key='locations'] | array[@key='locations']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="location" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='locations'][array/@key='STRVALUE'] |  array[@key='locations']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="locations">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='locations']/array[@key='STRVALUE']/string |  array[@key='locations']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling field "asset-type" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--host-item ssp-host-item-->
   <!--*[@key='host-item']/*[@key='asset-type'] | *[@key='asset-types'] | array[@key='asset-types']/* | *[@key='ssp-host-item']/*[@key='asset-type'] | *[@key='asset-types'] | array[@key='asset-types']/* | *[@key='ssp-host-item']/*/*[@key='asset-type'] | *[@key='asset-types'] | array[@key='asset-types']/* -->
   <!--*[@key='asset-type'] | *[@key='asset-types'] | array[@key='asset-types']/*-->
   <xsl:template match="*[@key='host-item']/*[@key='asset-type'] | *[@key='asset-types'] | array[@key='asset-types']/* | *[@key='ssp-host-item']/*[@key='asset-type'] | *[@key='asset-types'] | array[@key='asset-types']/* | *[@key='ssp-host-item']/*/*[@key='asset-type'] | *[@key='asset-types'] | array[@key='asset-types']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="asset-type" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='asset-types'][array/@key='STRVALUE'] |  array[@key='asset-types']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="asset-types">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='asset-types']/array[@key='STRVALUE']/string |  array[@key='asset-types']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling field "hardware-model" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--host-item ssp-host-item-->
   <!--*[@key='host-item']/*[@key='hardware-model'] | *[@key='hardware-models'] | array[@key='hardware-models']/* | *[@key='ssp-host-item']/*[@key='hardware-model'] | *[@key='hardware-models'] | array[@key='hardware-models']/* | *[@key='ssp-host-item']/*/*[@key='hardware-model'] | *[@key='hardware-models'] | array[@key='hardware-models']/* -->
   <!--*[@key='hardware-model'] | *[@key='hardware-models'] | array[@key='hardware-models']/*-->
   <xsl:template match="*[@key='host-item']/*[@key='hardware-model'] | *[@key='hardware-models'] | array[@key='hardware-models']/* | *[@key='ssp-host-item']/*[@key='hardware-model'] | *[@key='hardware-models'] | array[@key='hardware-models']/* | *[@key='ssp-host-item']/*/*[@key='hardware-model'] | *[@key='hardware-models'] | array[@key='hardware-models']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="hardware-model" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='hardware-models'][array/@key='STRVALUE'] |  array[@key='hardware-models']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="hardware-models">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='hardware-models']/array[@key='STRVALUE']/string |  array[@key='hardware-models']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling field "authenticated-scan" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--host-item ssp-host-item-->
   <!--*[@key='host-item']/*[@key='authenticated-scan'] | *[@key='authenticated-scans'] | array[@key='authenticated-scans']/* | *[@key='ssp-host-item']/*[@key='authenticated-scan'] | *[@key='authenticated-scans'] | array[@key='authenticated-scans']/* | *[@key='ssp-host-item']/*/*[@key='authenticated-scan'] | *[@key='authenticated-scans'] | array[@key='authenticated-scans']/* -->
   <!--*[@key='authenticated-scan'] | *[@key='authenticated-scans'] | array[@key='authenticated-scans']/*-->
   <xsl:template match="*[@key='host-item']/*[@key='authenticated-scan'] | *[@key='authenticated-scans'] | array[@key='authenticated-scans']/* | *[@key='ssp-host-item']/*[@key='authenticated-scan'] | *[@key='authenticated-scans'] | array[@key='authenticated-scans']/* | *[@key='ssp-host-item']/*/*[@key='authenticated-scan'] | *[@key='authenticated-scans'] | array[@key='authenticated-scans']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="authenticated-scan" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='authenticated-scans'][array/@key='STRVALUE'] |  array[@key='authenticated-scans']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="authenticated-scans">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='authenticated-scans']/array[@key='STRVALUE']/string |  array[@key='authenticated-scans']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling assembly "software-item" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='software-item'] | *[@key='ssp-software-item']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="software-item" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('vendor', 'vendors')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('software-name', 'software-names')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('software-version', 'software-versions')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('software-patch-level', 'software-patch-levels')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('function', 'functions')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-software-item']/*" priority="3" mode="json2xml">
      <xsl:element name="software-item" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('vendor', 'vendors')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('software-name', 'software-names')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('software-version', 'software-versions')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('software-patch-level', 'software-patch-levels')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('function', 'functions')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "software-name" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--software-item ssp-software-item-->
   <!--*[@key='software-item']/*[@key='software-name'] | *[@key='software-names'] | array[@key='software-names']/* | *[@key='ssp-software-item']/*[@key='software-name'] | *[@key='software-names'] | array[@key='software-names']/* | *[@key='ssp-software-item']/*/*[@key='software-name'] | *[@key='software-names'] | array[@key='software-names']/* -->
   <!--*[@key='software-name'] | *[@key='software-names'] | array[@key='software-names']/*-->
   <xsl:template match="*[@key='software-item']/*[@key='software-name'] | *[@key='software-names'] | array[@key='software-names']/* | *[@key='ssp-software-item']/*[@key='software-name'] | *[@key='software-names'] | array[@key='software-names']/* | *[@key='ssp-software-item']/*/*[@key='software-name'] | *[@key='software-names'] | array[@key='software-names']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="software-name" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='software-names'][array/@key='STRVALUE'] |  array[@key='software-names']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="software-names">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='software-names']/array[@key='STRVALUE']/string |  array[@key='software-names']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling field "software-version" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--software-item ssp-software-item-->
   <!--*[@key='software-item']/*[@key='software-version'] | *[@key='software-versions'] | array[@key='software-versions']/* | *[@key='ssp-software-item']/*[@key='software-version'] | *[@key='software-versions'] | array[@key='software-versions']/* | *[@key='ssp-software-item']/*/*[@key='software-version'] | *[@key='software-versions'] | array[@key='software-versions']/* -->
   <!--*[@key='software-version'] | *[@key='software-versions'] | array[@key='software-versions']/*-->
   <xsl:template match="*[@key='software-item']/*[@key='software-version'] | *[@key='software-versions'] | array[@key='software-versions']/* | *[@key='ssp-software-item']/*[@key='software-version'] | *[@key='software-versions'] | array[@key='software-versions']/* | *[@key='ssp-software-item']/*/*[@key='software-version'] | *[@key='software-versions'] | array[@key='software-versions']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="software-version" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='software-versions'][array/@key='STRVALUE'] |  array[@key='software-versions']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="software-versions">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='software-versions']/array[@key='STRVALUE']/string |  array[@key='software-versions']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling field "software-patch-level" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--software-item ssp-software-item-->
   <!--*[@key='software-item']/*[@key='software-patch-level'] | *[@key='software-patch-levels'] | array[@key='software-patch-levels']/* | *[@key='ssp-software-item']/*[@key='software-patch-level'] | *[@key='software-patch-levels'] | array[@key='software-patch-levels']/* | *[@key='ssp-software-item']/*/*[@key='software-patch-level'] | *[@key='software-patch-levels'] | array[@key='software-patch-levels']/* -->
   <!--*[@key='software-patch-level'] | *[@key='software-patch-levels'] | array[@key='software-patch-levels']/*-->
   <xsl:template match="*[@key='software-item']/*[@key='software-patch-level'] | *[@key='software-patch-levels'] | array[@key='software-patch-levels']/* | *[@key='ssp-software-item']/*[@key='software-patch-level'] | *[@key='software-patch-levels'] | array[@key='software-patch-levels']/* | *[@key='ssp-software-item']/*/*[@key='software-patch-level'] | *[@key='software-patch-levels'] | array[@key='software-patch-levels']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="software-patch-level" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='software-patch-levels'][array/@key='STRVALUE'] |  array[@key='software-patch-levels']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="software-patch-levels">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='software-patch-levels']/array[@key='STRVALUE']/string |  array[@key='software-patch-levels']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling field "function" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--software-item ssp-software-item-->
   <!--*[@key='software-item']/*[@key='function'] | *[@key='functions'] | array[@key='functions']/* | *[@key='ssp-software-item']/*[@key='function'] | *[@key='functions'] | array[@key='functions']/* | *[@key='ssp-software-item']/*/*[@key='function'] | *[@key='functions'] | array[@key='functions']/* -->
   <!--*[@key='function'] | *[@key='functions'] | array[@key='functions']/*-->
   <xsl:template match="*[@key='software-item']/*[@key='function'] | *[@key='functions'] | array[@key='functions']/* | *[@key='ssp-software-item']/*[@key='function'] | *[@key='functions'] | array[@key='functions']/* | *[@key='ssp-software-item']/*/*[@key='function'] | *[@key='functions'] | array[@key='functions']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="function" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='functions'][array/@key='STRVALUE'] |  array[@key='functions']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="functions">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='functions']/array[@key='STRVALUE']/string |  array[@key='functions']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling field "comments" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--inventory-item inventory-items-->
   <!--*[@key='inventory-item']/*[@key='comments'] | *[@key='inventory-items']/*[@key='comments'] | *[@key='inventory-items']/*/*[@key='comments'] -->
   <!--*[@key='comments']-->
   <xsl:template match="*[@key='inventory-item']/*[@key='comments'] | *[@key='inventory-items']/*[@key='comments'] | *[@key='inventory-items']/*/*[@key='comments'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="comments" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "serial-no" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--inventory-item inventory-items-->
   <!--*[@key='inventory-item']/*[@key='serial-no'] | *[@key='inventory-items']/*[@key='serial-no'] | *[@key='inventory-items']/*/*[@key='serial-no'] -->
   <!--*[@key='serial-no']-->
   <xsl:template match="*[@key='inventory-item']/*[@key='serial-no'] | *[@key='inventory-items']/*[@key='serial-no'] | *[@key='inventory-items']/*/*[@key='serial-no'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="serial-no" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "network-id" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--inventory-item inventory-items-->
   <!--*[@key='inventory-item']/*[@key='network-id'] | *[@key='network-ids'] | array[@key='network-ids']/* | *[@key='inventory-items']/*[@key='network-id'] | *[@key='network-ids'] | array[@key='network-ids']/* | *[@key='inventory-items']/*/*[@key='network-id'] | *[@key='network-ids'] | array[@key='network-ids']/* -->
   <!--*[@key='network-id'] | *[@key='network-ids'] | array[@key='network-ids']/*-->
   <xsl:template match="*[@key='inventory-item']/*[@key='network-id'] | *[@key='network-ids'] | array[@key='network-ids']/* | *[@key='inventory-items']/*[@key='network-id'] | *[@key='network-ids'] | array[@key='network-ids']/* | *[@key='inventory-items']/*/*[@key='network-id'] | *[@key='network-ids'] | array[@key='network-ids']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="network-id" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='network-ids'][array/@key='STRVALUE'] |  array[@key='network-ids']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="network-ids">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='network-ids']/array[@key='STRVALUE']/string |  array[@key='network-ids']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling field "asset-owner" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--inventory-item inventory-items-->
   <!--*[@key='inventory-item']/*[@key='asset-owner'] | *[@key='asset-owners'] | array[@key='asset-owners']/* | *[@key='inventory-items']/*[@key='asset-owner'] | *[@key='asset-owners'] | array[@key='asset-owners']/* | *[@key='inventory-items']/*/*[@key='asset-owner'] | *[@key='asset-owners'] | array[@key='asset-owners']/* -->
   <!--*[@key='asset-owner'] | *[@key='asset-owners'] | array[@key='asset-owners']/*-->
   <xsl:template match="*[@key='inventory-item']/*[@key='asset-owner'] | *[@key='asset-owners'] | array[@key='asset-owners']/* | *[@key='inventory-items']/*[@key='asset-owner'] | *[@key='asset-owners'] | array[@key='asset-owners']/* | *[@key='inventory-items']/*/*[@key='asset-owner'] | *[@key='asset-owners'] | array[@key='asset-owners']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="asset-owner" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='asset-owners'][array/@key='STRVALUE'] |  array[@key='asset-owners']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="asset-owners">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='asset-owners']/array[@key='STRVALUE']/string |  array[@key='asset-owners']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling field "asset-administrator" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--inventory-item inventory-items-->
   <!--*[@key='inventory-item']/*[@key='asset-administrator'] | *[@key='asset-administrators'] | array[@key='asset-administrators']/* | *[@key='inventory-items']/*[@key='asset-administrator'] | *[@key='asset-administrators'] | array[@key='asset-administrators']/* | *[@key='inventory-items']/*/*[@key='asset-administrator'] | *[@key='asset-administrators'] | array[@key='asset-administrators']/* -->
   <!--*[@key='asset-administrator'] | *[@key='asset-administrators'] | array[@key='asset-administrators']/*-->
   <xsl:template match="*[@key='inventory-item']/*[@key='asset-administrator'] | *[@key='asset-administrators'] | array[@key='asset-administrators']/* | *[@key='inventory-items']/*[@key='asset-administrator'] | *[@key='asset-administrators'] | array[@key='asset-administrators']/* | *[@key='inventory-items']/*/*[@key='asset-administrator'] | *[@key='asset-administrators'] | array[@key='asset-administrators']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="asset-administrator" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='asset-administrators'][array/@key='STRVALUE'] |  array[@key='asset-administrators']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="asset-administrators">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='asset-administrators']/array[@key='STRVALUE']/string |  array[@key='asset-administrators']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling assembly "control-implementation" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='control-implementation'] | *[@key='ssp-control-implementation']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="control-implementation" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('control', 'controls')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-control-implementation']/*"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="control-implementation" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('control', 'controls')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "control" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='control'] | *[@key='controls']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="control" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('responsible-role', 'ssp-responsible-role')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('set-param', 'parameter-settings')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('control-response', 'control-responses')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='controls']/*" priority="3" mode="json2xml">
      <xsl:element name="control" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('responsible-role', 'ssp-responsible-role')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('set-param', 'parameter-settings')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('control-response', 'control-responses')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "responsible-role" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--control controls-->
   <!--*[@key='control']/*[@key='responsible-role'] | *[@key='ssp-responsible-role'] | array[@key='ssp-responsible-role']/* | *[@key='controls']/*[@key='responsible-role'] | *[@key='ssp-responsible-role'] | array[@key='ssp-responsible-role']/* | *[@key='controls']/*/*[@key='responsible-role'] | *[@key='ssp-responsible-role'] | array[@key='ssp-responsible-role']/* -->
   <!--*[@key='responsible-role'] | *[@key='ssp-responsible-role'] | array[@key='ssp-responsible-role']/*-->
   <xsl:template match="*[@key='control']/*[@key='responsible-role'] | *[@key='ssp-responsible-role'] | array[@key='ssp-responsible-role']/* | *[@key='controls']/*[@key='responsible-role'] | *[@key='ssp-responsible-role'] | array[@key='ssp-responsible-role']/* | *[@key='controls']/*/*[@key='responsible-role'] | *[@key='ssp-responsible-role'] | array[@key='ssp-responsible-role']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="responsible-role" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='ssp-responsible-role'][array/@key='STRVALUE'] |  array[@key='ssp-responsible-role']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="ssp-responsible-role">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='ssp-responsible-role']/array[@key='STRVALUE']/string |  array[@key='ssp-responsible-role']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling assembly "set-param" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='set-param'] | *[@key='parameter-settings']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="set-param" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('value')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='parameter-settings']/*" priority="3" mode="json2xml">
      <xsl:element name="set-param" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('value')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "value" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--set-param parameter-settings-->
   <!--*[@key='set-param']/*[@key='value'] | *[@key='parameter-settings']/*[@key='value'] | *[@key='parameter-settings']/*/*[@key='value'] -->
   <!--*[@key='value']-->
   <xsl:template match="*[@key='set-param']/*[@key='value'] | *[@key='parameter-settings']/*[@key='value'] | *[@key='parameter-settings']/*/*[@key='value'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="value" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "control-response" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='control-response'] | *[@key='control-responses']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="control-response" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key='prose']"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='control-responses']/*" priority="3" mode="json2xml">
      <xsl:element name="control-response" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key='prose']"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "references" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='references']" priority="4" mode="json2xml">
      <xsl:element name="references" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('ref', 'refs')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "ref" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='ref'] | *[@key='refs']" priority="4" mode="json2xml">
      <xsl:element name="ref" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('citation', 'citations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key='prose']"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='refs']/*" priority="3" mode="json2xml">
      <xsl:element name="ref" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('citation', 'citations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key='prose']"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "citation" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--ref refs-->
   <!--*[@key='ref']/*[@key='citation'] | *[@key='citations'] | array[@key='citations']/* | *[@key='refs']/*[@key='citation'] | *[@key='citations'] | array[@key='citations']/* | *[@key='refs']/*/*[@key='citation'] | *[@key='citations'] | array[@key='citations']/* -->
   <!--*[@key='citation'] | *[@key='citations'] | array[@key='citations']/*-->
   <xsl:template match="*[@key='ref']/*[@key='citation'] | *[@key='citations'] | array[@key='citations']/* | *[@key='refs']/*[@key='citation'] | *[@key='citations'] | array[@key='citations']/* | *[@key='refs']/*/*[@key='citation'] | *[@key='citations'] | array[@key='citations']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="citation" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:for-each select="string[@key='RICHTEXT'], self::string">
            <xsl:variable name="markup">
               <xsl:apply-templates mode="infer-inlines"/>
            </xsl:variable>
            <xsl:apply-templates mode="cast-ns" select="$markup"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='citations'][array/@key='RICHTEXT'] |  array[@key='citations']/map[array/@key='RICHTEXT']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="citations">
            <xsl:apply-templates mode="expand" select="array[@key='RICHTEXT']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='citations']/array[@key='RICHTEXT']/string |  array[@key='citations']/map/array[@key='RICHTEXT']/string">
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
   <!-- 000 Handling field "link" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--metadata references-->
   <!--*[@key='metadata']/*[@key='link'] | *[@key='links'] | array[@key='links']/* | *[@key='references']/*[@key='link'] | *[@key='links'] | array[@key='links']/*-->
   <!--*[@key='link'] | *[@key='links'] | array[@key='links']/*-->
   <xsl:template match="*[@key='metadata']/*[@key='link'] | *[@key='links'] | array[@key='links']/* | *[@key='references']/*[@key='link'] | *[@key='links'] | array[@key='links']/*"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="link" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:for-each select="string[@key='RICHTEXT'], self::string">
            <xsl:variable name="markup">
               <xsl:apply-templates mode="infer-inlines"/>
            </xsl:variable>
            <xsl:apply-templates mode="cast-ns" select="$markup"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='links'][array/@key='RICHTEXT'] |  array[@key='links']/map[array/@key='RICHTEXT']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="links">
            <xsl:apply-templates mode="expand" select="array[@key='RICHTEXT']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='links']/array[@key='RICHTEXT']/string |  array[@key='links']/map/array[@key='RICHTEXT']/string">
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
   <!-- 000 Handling assembly "attachment" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='attachment']" priority="4" mode="json2xml">
      <xsl:element name="attachment" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('format')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('date')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('version')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('attachment-type')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('base64')]"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "format" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--attachment-->
   <!--*[@key='attachment']/*[@key='format']-->
   <!--*[@key='format']-->
   <xsl:template match="*[@key='attachment']/*[@key='format']"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="format" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "date" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--attachment-->
   <!--*[@key='attachment']/*[@key='date']-->
   <!--*[@key='date']-->
   <xsl:template match="*[@key='attachment']/*[@key='date']"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="date" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "attachment-type" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--attachment-->
   <!--*[@key='attachment']/*[@key='attachment-type']-->
   <!--*[@key='attachment-type']-->
   <xsl:template match="*[@key='attachment']/*[@key='attachment-type']"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="attachment-type" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "base64" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--resource resources attachment-->
   <!--*[@key='resource']/*[@key='base64'] | *[@key='attachment']/*[@key='base64'] | *[@key='resources']/*[@key='base64'] | *[@key='resources']/*/*[@key='base64'] -->
   <!--*[@key='base64']-->
   <xsl:template match="*[@key='resource']/*[@key='base64'] | *[@key='attachment']/*[@key='base64'] | *[@key='resources']/*[@key='base64'] | *[@key='resources']/*/*[@key='base64'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="base64" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling flag "attachment-id" 000 -->
   <xsl:template match="*[@key='attachment-id']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='boundary-diagram']/*[@key='attachment-id'] | *[@key='ssp-boundary-diagram']/*[@key='attachment-id'] | array[@key='ssp-boundary-diagram']/*/*[@key='attachment-id'] | *[@key='network-diagram']/*[@key='attachment-id'] | *[@key='ssp-network-boundary']/*[@key='attachment-id'] | array[@key='ssp-network-boundary']/*/*[@key='attachment-id'] | *[@key='data-flow-diagram']/*[@key='attachment-id'] | *[@key='ssp-data-flow-diagram']/*[@key='attachment-id'] | array[@key='ssp-data-flow-diagram']/*/*[@key='attachment-id']"
                 mode="as-attribute">
      <xsl:attribute name="attachment-id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "component-id" 000 -->
   <xsl:template match="*[@key='component-id']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='inventory-item']/*[@key='component-id'] | *[@key='inventory-items']/*[@key='component-id'] | array[@key='inventory-items']/*/*[@key='component-id']"
                 mode="as-attribute">
      <xsl:attribute name="component-id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "control-id" 000 -->
   <xsl:template match="*[@key='control-id']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='call']/*[@key='control-id'] | *[@key='id-selectors']/*[@key='control-id'] | array[@key='id-selectors']/*/*[@key='control-id'] | *[@key='control']/*[@key='control-id'] | *[@key='controls']/*[@key='control-id'] | array[@key='controls']/*/*[@key='control-id']"
                 mode="as-attribute">
      <xsl:attribute name="control-id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "stmt-id" 000 -->
   <xsl:template match="*[@key='stmt-id']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='control-response']/*[@key='stmt-id'] | *[@key='control-responses']/*[@key='stmt-id'] | array[@key='control-responses']/*/*[@key='stmt-id']"
                 mode="as-attribute">
      <xsl:attribute name="stmt-id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "nist-id" 000 -->
   <xsl:template match="*[@key='nist-id']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='information-type']/*[@key='nist-id'] | *[@key='ssp-information-type']/*[@key='nist-id'] | array[@key='ssp-information-type']/*/*[@key='nist-id']"
                 mode="as-attribute">
      <xsl:attribute name="nist-id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "poc-id" 000 -->
   <xsl:template match="*[@key='poc-id']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='asset-owner']/*[@key='poc-id'] | *[@key='asset-owners']/*[@key='poc-id'] | array[@key='asset-owners']/*/*[@key='poc-id'] | *[@key='asset-administrator']/*[@key='poc-id'] | *[@key='asset-administrators']/*[@key='poc-id'] | array[@key='asset-administrators']/*/*[@key='poc-id']"
                 mode="as-attribute">
      <xsl:attribute name="poc-id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "param-id" 000 -->
   <xsl:template match="*[@key='param-id']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='set-param']/*[@key='param-id'] | *[@key='parameter-settings']/*[@key='param-id'] | array[@key='parameter-settings']/*/*[@key='param-id']"
                 mode="as-attribute">
      <xsl:attribute name="param-id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "ref-type" 000 -->
   <xsl:template match="*[@key='ref-type']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='ref']/*[@key='ref-type'] | *[@key='refs']/*[@key='ref-type'] | array[@key='refs']/*/*[@key='ref-type']"
                 mode="as-attribute">
      <xsl:attribute name="ref-type">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "target" 000 -->
   <xsl:template match="*[@key='target']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='set-param']/*[@key='target'] | *[@key='parameter-settings']/*[@key='target'] | array[@key='parameter-settings']/*/*[@key='target']"
                 mode="as-attribute">
      <xsl:attribute name="target">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
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
   <!-- 000 Handling flag "role-id" 000 -->
   <xsl:template match="*[@key='role-id']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='party']/*[@key='role-id'] | *[@key='parties']/*[@key='role-id'] | array[@key='parties']/*/*[@key='role-id'] | *[@key='responsible-role']/*[@key='role-id'] | *[@key='ssp-responsible-role']/*[@key='role-id'] | array[@key='ssp-responsible-role']/*/*[@key='role-id']"
                 mode="as-attribute">
      <xsl:attribute name="role-id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "class" 000 -->
   <xsl:template match="*[@key='class']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='prop']/*[@key='class'] | *[@key='properties']/*[@key='class'] | array[@key='properties']/*/*[@key='class'] | *[@key='part']/*[@key='class'] | *[@key='ssp-part']/*[@key='class'] | array[@key='ssp-part']/*/*[@key='class'] | *[@key='control']/*[@key='class'] | *[@key='controls']/*[@key='class'] | array[@key='controls']/*/*[@key='class']"
                 mode="as-attribute">
      <xsl:attribute name="class">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "context" 000 -->
   <xsl:template match="*[@key='context']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='characteristics']/*[@key='context'] | *[@key='ssp-characteristics']/*[@key='context'] | array[@key='ssp-characteristics']/*/*[@key='context'] | *[@key='satisfaction']/*[@key='context'] | *[@key='ssp-satisfaction']/*[@key='context'] | array[@key='ssp-satisfaction']/*/*[@key='context']"
                 mode="as-attribute">
      <xsl:attribute name="context">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "name" 000 -->
   <xsl:template match="*[@key='name']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='prop']/*[@key='name'] | *[@key='properties']/*[@key='name'] | array[@key='properties']/*/*[@key='name'] | *[@key='role']/*[@key='name'] | *[@key='roles']/*[@key='name'] | array[@key='roles']/*/*[@key='name'] | *[@key='service']/*[@key='name'] | *[@key='ssp-service']/*[@key='name'] | array[@key='ssp-service']/*/*[@key='name'] | *[@key='protocol']/*[@key='name'] | *[@key='ssp-protocol']/*[@key='name'] | array[@key='ssp-protocol']/*/*[@key='name']"
                 mode="as-attribute">
      <xsl:attribute name="name">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "start" 000 -->
   <xsl:template match="*[@key='start']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='port-range']/*[@key='start'] | *[@key='port-ranges']/*[@key='start'] | array[@key='port-ranges']/*/*[@key='start']"
                 mode="as-attribute">
      <xsl:attribute name="start">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "end" 000 -->
   <xsl:template match="*[@key='end']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='port-range']/*[@key='end'] | *[@key='port-ranges']/*[@key='end'] | array[@key='port-ranges']/*/*[@key='end']"
                 mode="as-attribute">
      <xsl:attribute name="end">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "transport" 000 -->
   <xsl:template match="*[@key='transport']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='port-range']/*[@key='transport'] | *[@key='port-ranges']/*[@key='transport'] | array[@key='port-ranges']/*/*[@key='transport']"
                 mode="as-attribute">
      <xsl:attribute name="transport">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "type" 000 -->
   <xsl:template match="*[@key='type']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='doc-id']/*[@key='type'] | *[@key='document-ids']/*[@key='type'] | array[@key='document-ids']/*/*[@key='type'] | *[@key='person-id']/*[@key='type'] | *[@key='person-ids']/*[@key='type'] | array[@key='person-ids']/*/*[@key='type'] | *[@key='org-id']/*[@key='type'] | *[@key='organization-ids']/*[@key='type'] | array[@key='organization-ids']/*/*[@key='type'] | *[@key='address']/*[@key='type'] | *[@key='addresses']/*[@key='type'] | array[@key='addresses']/*/*[@key='type'] | *[@key='phone']/*[@key='type'] | *[@key='telephone-numbers']/*[@key='type'] | array[@key='telephone-numbers']/*/*[@key='type'] | *[@key='notes']/*[@key='type'] | *[@key='system-id']/*[@key='type'] | *[@key='component']/*[@key='type'] | *[@key='components']/*[@key='type'] | array[@key='components']/*/*[@key='type'] | *[@key='vendor']/*[@key='type'] | *[@key='vendors']/*[@key='type'] | array[@key='vendors']/*/*[@key='type'] | *[@key='ip-address']/*[@key='type'] | *[@key='ip-addresses']/*[@key='type'] | array[@key='ip-addresses']/*/*[@key='type']"
                 mode="as-attribute">
      <xsl:attribute name="type">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "public" 000 -->
   <xsl:template match="*[@key='public']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='inventory-item']/*[@key='public'] | *[@key='inventory-items']/*[@key='public'] | array[@key='inventory-items']/*/*[@key='public']"
                 mode="as-attribute">
      <xsl:attribute name="public">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "virtual" 000 -->
   <xsl:template match="*[@key='virtual']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='inventory-item']/*[@key='virtual'] | *[@key='inventory-items']/*[@key='virtual'] | array[@key='inventory-items']/*/*[@key='virtual']"
                 mode="as-attribute">
      <xsl:attribute name="virtual">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "external" 000 -->
   <xsl:template match="*[@key='external']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='role']/*[@key='external'] | *[@key='roles']/*[@key='external'] | array[@key='roles']/*/*[@key='external']"
                 mode="as-attribute">
      <xsl:attribute name="external">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "access" 000 -->
   <xsl:template match="*[@key='access']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='role']/*[@key='access'] | *[@key='roles']/*[@key='access'] | array[@key='roles']/*/*[@key='access']"
                 mode="as-attribute">
      <xsl:attribute name="access">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling flag "sensitivity-level" 000 -->
   <xsl:template match="*[@key='sensitivity-level']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='role']/*[@key='sensitivity-level'] | *[@key='roles']/*[@key='sensitivity-level'] | array[@key='roles']/*/*[@key='sensitivity-level']"
                 mode="as-attribute">
      <xsl:attribute name="sensitivity-level">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 000 Handling assembly "validation" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='validation'] | *[@key='validations']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="validation" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key='prose']"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='validations']/*" priority="3" mode="json2xml">
      <xsl:element name="validation" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key='prose']"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling assembly "provisioning" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <xsl:template match="*[@key='provisioning'] | *[@key='ssp-provisioning']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="provisioning" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key='prose']"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key='ssp-provisioning']/*" priority="3" mode="json2xml">
      <xsl:element name="provisioning" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key='prose']"/>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "subcomponent" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--component components-->
   <!--*[@key='component']/*[@key='subcomponent'] | *[@key='subcomponents'] | array[@key='subcomponents']/* | *[@key='components']/*[@key='subcomponent'] | *[@key='subcomponents'] | array[@key='subcomponents']/* | *[@key='components']/*/*[@key='subcomponent'] | *[@key='subcomponents'] | array[@key='subcomponents']/* -->
   <!--*[@key='subcomponent'] | *[@key='subcomponents'] | array[@key='subcomponents']/*-->
   <xsl:template match="*[@key='component']/*[@key='subcomponent'] | *[@key='subcomponents'] | array[@key='subcomponents']/* | *[@key='components']/*[@key='subcomponent'] | *[@key='subcomponents'] | array[@key='subcomponents']/* | *[@key='components']/*/*[@key='subcomponent'] | *[@key='subcomponents'] | array[@key='subcomponents']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="subcomponent" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='subcomponents'][array/@key='STRVALUE'] |  array[@key='subcomponents']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="subcomponents">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='subcomponents']/array[@key='STRVALUE']/string |  array[@key='subcomponents']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling field "organization" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--origin ssp-origin-->
   <!--*[@key='origin']/*[@key='organization'] | *[@key='ssp-origin']/*[@key='organization'] | *[@key='ssp-origin']/*/*[@key='organization'] -->
   <!--*[@key='organization']-->
   <xsl:template match="*[@key='origin']/*[@key='organization'] | *[@key='ssp-origin']/*[@key='organization'] | *[@key='ssp-origin']/*/*[@key='organization'] "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="organization" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- 000 Handling field "baseline-template" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--host-item ssp-host-item-->
   <!--*[@key='host-item']/*[@key='baseline-template'] | *[@key='baseline-templates'] | array[@key='baseline-templates']/* | *[@key='ssp-host-item']/*[@key='baseline-template'] | *[@key='baseline-templates'] | array[@key='baseline-templates']/* | *[@key='ssp-host-item']/*/*[@key='baseline-template'] | *[@key='baseline-templates'] | array[@key='baseline-templates']/* -->
   <!--*[@key='baseline-template'] | *[@key='baseline-templates'] | array[@key='baseline-templates']/*-->
   <xsl:template match="*[@key='host-item']/*[@key='baseline-template'] | *[@key='baseline-templates'] | array[@key='baseline-templates']/* | *[@key='ssp-host-item']/*[@key='baseline-template'] | *[@key='baseline-templates'] | array[@key='baseline-templates']/* | *[@key='ssp-host-item']/*/*[@key='baseline-template'] | *[@key='baseline-templates'] | array[@key='baseline-templates']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="baseline-template" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='baseline-templates'][array/@key='STRVALUE'] |  array[@key='baseline-templates']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="baseline-templates">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='baseline-templates']/array[@key='STRVALUE']/string |  array[@key='baseline-templates']/map/array[@key='STRVALUE']/string">
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
   <!-- 000 Handling field "scanned" 000 -->
   <!-- 000 NB - template matching 'array' overrides this one 000 -->
   <!--host-item ssp-host-item-->
   <!--*[@key='host-item']/*[@key='scanned'] | *[@key='ssp-scanned'] | array[@key='ssp-scanned']/* | *[@key='ssp-host-item']/*[@key='scanned'] | *[@key='ssp-scanned'] | array[@key='ssp-scanned']/* | *[@key='ssp-host-item']/*/*[@key='scanned'] | *[@key='ssp-scanned'] | array[@key='ssp-scanned']/* -->
   <!--*[@key='scanned'] | *[@key='ssp-scanned'] | array[@key='ssp-scanned']/*-->
   <xsl:template match="*[@key='host-item']/*[@key='scanned'] | *[@key='ssp-scanned'] | array[@key='ssp-scanned']/* | *[@key='ssp-host-item']/*[@key='scanned'] | *[@key='ssp-scanned'] | array[@key='ssp-scanned']/* | *[@key='ssp-host-item']/*/*[@key='scanned'] | *[@key='ssp-scanned'] | array[@key='ssp-scanned']/* "
                 priority="5"
                 mode="json2xml">
      <xsl:element name="scanned" namespace="urn:OSCAL-SSP-metaschema">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key='ssp-scanned'][array/@key='STRVALUE'] |  array[@key='ssp-scanned']/map[array/@key='STRVALUE']"
                 priority="3"
                 mode="json2xml">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="ssp-scanned">
            <xsl:apply-templates mode="expand" select="array[@key='STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key='ssp-scanned']/array[@key='STRVALUE']/string |  array[@key='ssp-scanned']/map/array[@key='STRVALUE']/string">
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
