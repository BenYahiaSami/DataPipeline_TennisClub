<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT stylesheet that converts TENNIS_CLUB member data into JSON-like text -->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Output plain text because we are building JSON manually -->
	<xsl:output method="text" encoding="UTF-8"/>

	<!-- Start from the root of the XML document -->
	<xsl:template match="/">
		{
		"membersMembershipReport": [
				<!-- Loop through every MEMBER in the club -->
		<xsl:for-each select="/TENNIS_CLUB/MEMBERS/MEMBER">
			{
						<!-- Read the member Id attribute -->
			"memberId": "			<xsl:value-of select="@Id"/>
",

						<!-- Build full name from first name and last name -->
			"fullName": "			<xsl:value-of select="concat(INFORMATION/FIRST_NAME, ' ', INFORMATION/LAST_NAME)"/>
",

						<!-- Count how many memberships this member has -->
			"membershipsCount":			<xsl:value-of select="count(MEMBERSHIPS/MEMBERSHIP)"/>
,

						<!-- Read the level of the last membership -->
			"lastMembershipLevel": "			<xsl:value-of select="MEMBERSHIPS/MEMBERSHIP[last()]/MEMBERLEVEL"/>
",

						<!-- Check whether the last membership is still active -->
			<!-- Here, a membership is considered active if its END_DATE year is greater than 2025 -->
			"status": "			<xsl:choose>
				<xsl:when test="number(substring(MEMBERSHIPS/MEMBERSHIP[last()]/END_DATE,1,4)) &gt; 2025">active</xsl:when>
				<xsl:otherwise>expired</xsl:otherwise>
			</xsl:choose>"
			}			<xsl:if test="position() != last()">,</xsl:if>
		</xsl:for-each>
		]
		}
	</xsl:template>

</xsl:stylesheet>