<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xsl tei xd eg fn #default" extension-element-prefixes="exsl     msxsl" version="1.0"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:eg="http://www.tei-c.org/ns/Examples" xmlns:exsl="http://exslt.org/common"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:msxsl="urn:schemas-microsoft-com:xslt"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- construct the image URL on the fly -->
    <xsl:variable name="v_volume" select="$vgBiblStructSource/tei:monogr/tei:biblScope[@unit = 'volume']/@n"/>
    <xsl:variable name="v_issue" select="$vgBiblStructSource/tei:monogr/tei:biblScope[@unit = 'issue']/@n"/>

    <!-- could also select pb[@facs] -->
    <xsl:template match="tei:pb[@ed = 'print']">
        <!--<xsl:param name="pn">
            <xsl:number count="//tei:pb" level="any"/>
        </xsl:param>-->
        <xsl:choose>
            <xsl:when test="$displayPageBreaks = true()">
                <!-- add @lang="en" to ensure correct ltr rendering -->
                <span class="-teibp-pb" lang="en">
                    <xsl:call-template name="addID"/>
                    <xsl:call-template name="t_handler-pb">
                        <xsl:with-param name="p_n" select="@n"/>
                        <xsl:with-param name="p_facs" select="@facs"/>
                        <xsl:with-param name="p_id">
                            <xsl:choose>
                                <xsl:when test="@xml:id">
                                    <xsl:value-of select="@xml:id"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="generate-id()"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="t_handler-pb">
        <xsl:param name="p_n"/>
        <xsl:param name="p_facs"/>
        <xsl:param name="p_id"/>
        <xsl:variable name="v_id-facs" select="substring-after($p_facs, '#')"/>
        <xsl:variable name="v_graphic" select="ancestor::tei:TEI/tei:facsimile/tei:surface[@xml:id = $v_id-facs]/tei:graphic"/>
        <!-- select which online facsimile to display based on the order of preference: EAP, sakhrit, HathiTrust, other; and https over http -->
        <xsl:variable name="v_url-graphic">
            <xsl:choose>
                <xsl:when test="$v_graphic[starts-with(@url, 'https://eap.')]">
                    <xsl:value-of select="$v_graphic[starts-with(@url, 'https://eap.')][1]/@url"/>
                </xsl:when>
                <xsl:when test="$v_graphic[starts-with(@url, 'http://eap.')]">
                    <xsl:value-of select="$v_graphic[starts-with(@url, 'http://eap.')][1]/@url"/>
                </xsl:when>
                <xsl:when test="$v_graphic[starts-with(@url, 'http://archive.sakhrit.co')]">
                    <xsl:value-of select="$v_graphic[starts-with(@url, 'http://archive.sakhrit.co')][1]/@url"/>
                </xsl:when>
                <xsl:when test="$v_graphic[starts-with(@url, 'https://babel.hathitrust.org')]">
                    <xsl:value-of select="$v_graphic[starts-with(@url, 'https://babel.hathitrust.org')][1]/@url"/>
                </xsl:when>
                <xsl:when test="$v_graphic[starts-with(@url, 'http://babel.hathitrust.org')]">
                    <xsl:value-of select="$v_graphic[starts-with(@url, 'http://babel.hathitrust.org')][1]/@url"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$v_graphic[starts-with(@url, 'http')][1]/@url"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- dealing with pointers instead of full URLs in @facs -->
        <xsl:variable name="v_url-facs">
            <xsl:choose>
                <xsl:when test="starts-with($p_facs, '#')">
                    <!-- Preference:  -->
                    <xsl:choose>
                        <xsl:when test="$pgOnlineFacs = true()">
                            <xsl:value-of select="$v_url-graphic"/>
                        </xsl:when>
                        <!-- select the local file -->
                        <xsl:otherwise>
                            <xsl:value-of select="$v_graphic[@mimeType = $vMimeType][1]/@url"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$p_facs"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="v_url-facs-online">
            <xsl:choose>
                <xsl:when test="starts-with($p_facs, '#')">
                    <xsl:value-of select="$v_url-graphic"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$p_facs"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="v_facs-source">
            <xsl:choose>
                <xsl:when test="$v_graphic[contains(@url, '://eap.')]">
                    <xsl:text>EAP</xsl:text>
                </xsl:when>
                <xsl:when test="$v_graphic[contains(@url, '://archive.sakhrit.co')]">
                    <xsl:text>archive.sakhrit.co</xsl:text>
                </xsl:when>
                <xsl:when test="$v_graphic[contains(@url, '://babel.hathitrust.org')]">
                    <xsl:text>HathiTrust</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>source</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <span class="-teibp-pageNum" lang="en">
            <!-- <xsl:call-template name="atts"/> -->
            <xsl:copy-of select="$pbNote"/>
            <xsl:value-of select="@n"/>
            <!-- provide link to online facsimile no matter what -->
            <xsl:if test="$p_facs = true()">
                <xsl:text> - </xsl:text>
                <a href="{$v_url-facs-online}" target="_blank">
                    <xsl:value-of select="$altTextPbFacs"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="$v_facs-source"/>
                </a>
            </xsl:if>
        </span>
        <xsl:if test="$p_facs = true()">
            <span class="-teibp-pbFacs" lang="en">
                <a class="gallery-facs" lang="en" href="{$v_url-facs}" target="_blank">
                    <!-- <a class="gallery-facs" rel="prettyPhoto[gallery1]" lang="en"> -->
                    <!-- <xsl:attribute name="onclick">
                    <xsl:value-of select="concat('showFacs(', $apos, $p_n, $apos, ',', $apos, $v_url-facs, $apos, ',', $apos, $p_id, $apos, ')')"/>
                </xsl:attribute> -->
                    <img alt="{$altTextPbFacs}" class="-teibp-thumbnail">
                        <xsl:attribute name="src">
                            <xsl:value-of select="$v_url-facs"/>
                        </xsl:attribute>
                    </img>
                </a>
            </span>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
