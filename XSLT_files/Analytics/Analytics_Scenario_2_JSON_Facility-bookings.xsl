<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT stylesheet that converts facility booking data into JSON-like text -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Output plain text because we are building JSON manually -->
  <xsl:output method="text" encoding="UTF-8"/>

  <!-- Start from the root of the XML document -->
  <xsl:template match="/">
{
  "facilityBookingsAnalytics": [
        <!-- Loop through every facility in the club -->
    <xsl:for-each select="/TENNIS_CLUB/FACILITIES/FACILITY">

      <!-- Store the current facility ID -->
      <xsl:variable name="facilityId" select="@Id"/>

      <!-- Count how many bookings are linked to this facility -->
      <xsl:variable name="bookingsCount" select="count(/TENNIS_CLUB/BOOKINGS/BOOKING[FACILITYID = $facilityId])"/>

    {
            <!-- Facility identifier -->
      "facilityID": "      <xsl:value-of select="$facilityId"/>
",

            <!-- Facility type -->
      "facilityType": "      <xsl:value-of select="FACILITYTYPE"/>
",

            <!-- Surface type -->
      "groundType": "      <xsl:value-of select="SURFACETYPE"/>
",

            <!-- Current facility state -->
      "state": "      <xsl:value-of select="STATE"/>
",

            <!-- Number of bookings for this facility -->
      "bookingsCount":      <xsl:value-of select="$bookingsCount"/>
,

            <!-- Usage category based on number of bookings -->
      "usageCategory": "      <xsl:choose>
        <xsl:when test="$bookingsCount = 0">Low</xsl:when>
        <xsl:when test="$bookingsCount = 1">Medium</xsl:when>
        <xsl:otherwise>High</xsl:otherwise>
      </xsl:choose>"
    }      <xsl:if test="position() != last()">,</xsl:if>

    </xsl:for-each>
  ]
}
  </xsl:template>

</xsl:stylesheet>