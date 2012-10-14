<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:strip-space elements="*" />
	<xsl:template match="/">
		<osm version="0.6">
			<xsl:apply-templates />
		</osm>
	</xsl:template>
	<xsl:template match="/osm/bounds">
		<xsl:copy />
	</xsl:template>
	<xsl:template match="/osm/bound">
		<xsl:param
			name="bounds"
			select="str:tokenize(./@box, ',')"
			xmlns:str="http://exslt.org/strings" />
		<bounds>
			<xsl:attribute name="minlat">
				<xsl:value-of select="$bounds[1]" />
			</xsl:attribute>
			<xsl:attribute name="minlon">
				<xsl:value-of select="$bounds[2]" />
			</xsl:attribute>
			<xsl:attribute name="maxlat">
				<xsl:value-of select="$bounds[3]" />
			</xsl:attribute>
			<xsl:attribute name="maxlon">
				<xsl:value-of select="$bounds[4]" />
			</xsl:attribute>
		</bounds>
	</xsl:template>
	<xsl:template match="/osm/node">
		<xsl:copy>
			<xsl:copy-of select="(@*)[name() = 'lat' or name() = 'lon' or name() = 'id']" />
		</xsl:copy>
	</xsl:template>
	<xsl:template match="/osm/way">
		<xsl:copy>
			<xsl:copy-of select="(@*)[name() = 'id']" />
			<xsl:apply-templates />
		</xsl:copy>
	</xsl:template>
	<xsl:template match="/osm/way/nd">
		<xsl:copy>
			<xsl:copy-of select="(@*)[name() = 'ref']"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
