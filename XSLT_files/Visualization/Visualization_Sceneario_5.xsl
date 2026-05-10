<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" encoding="UTF-8" />

    <!-- Variation of the recuirsive function of the Scenario 4. The difference is that the template must get and sum the duration of two different XPath and must work accordingly if one of the XPath is over before the other-->
    <xsl:template name ="sumMinutes">
        <xsl:param name="bookings"/>
        <xsl:param name="sessions"/>
        <xsl:param name="accumulator" select = "0"/>
        <xsl:choose>
            <xsl:when test="$bookings and $sessions">                <!-- In the case both lists still have elmements-->
                <xsl:variable name="currentB" select="$bookings[1]"/>
                <xsl:variable name="currentS" select="$sessions[1]"/>

                <xsl:variable name="duration" select="
                  ( number(substring($currentB/DATE_HOUR_END,12,2))   * 60 + number(substring($currentB/DATE_HOUR_END,15,2))   )
                - ( number(substring($currentB/DATE_HOUR_BEGIN,12,2)) * 60 + number(substring($currentB/DATE_HOUR_BEGIN,15,2)) )
                + ( number(substring($currentS/DATE_HOUR_END,12,2))   * 60 + number(substring($currentS/DATE_HOUR_END,15,2))   )
                - ( number(substring($currentS/DATE_HOUR_BEGIN,12,2)) * 60 + number(substring($currentS/DATE_HOUR_BEGIN,15,2)) )"/>

                <xsl:call-template name="sumMinutes">
                    <xsl:with-param name="sessions" select="$sessions[position() > 1]"/>
                    <xsl:with-param name ="bookings" select= "$bookings[position() > 1]"/>
                    <xsl:with-param name="accumulator" select="$accumulator + $duration"></xsl:with-param>
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$bookings and not($sessions)">
                <xsl:variable name="currentB" select="$bookings[1]"/>
                <xsl:variable name="duration" select="
                  ( number(substring($currentB/DATE_HOUR_END,12,2))   * 60 + number(substring($currentB/DATE_HOUR_END,15,2))   )
                - ( number(substring($currentB/DATE_HOUR_BEGIN,12,2)) * 60 + number(substring($currentB/DATE_HOUR_BEGIN,15,2)) )"/>

                <xsl:call-template name="sumMinutes">
                    <xsl:with-param name="bookings" select="$bookings[position() > 1]"/>
                    <!-- sessions exhausted: omitting the param intentionaly-->
                    <xsl:with-param name="accumulator" select="$accumulator + $duration"></xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="not($bookings) and $sessions">
                <xsl:variable name="currentS" select="$sessions[1]"/>

                <xsl:variable name="duration" select="
                  ( number(substring($currentS/DATE_HOUR_END,12,2))   * 60 + number(substring($currentS/DATE_HOUR_END,15,2))   )
                - ( number(substring($currentS/DATE_HOUR_BEGIN,12,2)) * 60 + number(substring($currentS/DATE_HOUR_BEGIN,15,2)) )"/>

                <xsl:call-template name="sumMinutes">
                    <xsl:with-param name="sessions" select="$sessions[position() > 1]"/>
                    <!-- bookings exhausted: omitting the param intentionaly-->
                    <xsl:with-param name="accumulator" select="$accumulator + $duration"></xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$accumulator" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="/">
        <html>
            <head>
                <title> Hours of use of each facilities </title>
                <style>
                    body {
                        font-family: Arial;
                        max-width: 600px;
                        margin: 40px auto;
                        background-color: #E8E8E8;
                    }
                    h1 {
                        color: #871500;
                        border-bottom: 2px solid #871500;
                        padding-bottom: 10px;
                        margin-bottom: 5%;
                    }
                    table {
                        width: 100%;
                        border-collapse: collapse;
                        background: white;
                        box-shadow: 1px 1px 10px rgba(0,0,0,0.5);
                    }
                    th {
                        background-color: #871500;
                        color: white;
                        padding: 10px 14px;
                        text-align: left;
                    }
                    td {
                        padding: 8px 14px;
                        border-bottom: 1px solid #e0e0e0;
                        text-align: left;
                    }
                    tr:nth-child(even) td {
                        background-color: #EBEBEB;
                    }
                </style>
            </head>
            <body>
                <h1>Below the facilities Id followed by their hours of utilisation :</h1>
                <table>
                    <thead>
                        <tr>
                            <th>Facility Id</th>
                            <th>Facility Type</th>
                            <th>Surface Type</th>
                            <th>Use Duration</th>
                        </tr>
                    </thead>

                    <tbody>
                        <xsl:for-each select="TENNIS_CLUB/FACILITIES/FACILITY[not(@Id=preceding::FACILITIES/FACILITY/@Id)]">
                            <xsl:variable name="facilityId" select="@Id"/>
                            <xsl:variable name ="facilityType" select = "/TENNIS_CLUB/FACILITIES/FACILITY[@Id = $facilityId]/FACILITYTYPE" />
                            <xsl:variable name ="surfaceType" select = "/TENNIS_CLUB/FACILITIES/FACILITY[@Id = $facilityId]/SURFACETYPE" />

                            <xsl:variable name = "totalMinutes">
                                <xsl:call-template name = "sumMinutes">
                                    <xsl:with-param name = "sessions" select ="/TENNIS_CLUB/TRAINING_SESSIONS/TRAINING_SESSION[FACILITYID = $facilityId]"/>
                                    <xsl:with-param name = "bookings" select ="/TENNIS_CLUB/BOOKINGS/BOOKING[FACILITYID = $facilityId]"/>
                                </xsl:call-template>
                            </xsl:variable>

                            <tr>
                                <td>
                                    <xsl:value-of select="$facilityId" />
                                </td>

                                <td>
                                    <xsl:value-of select="$facilityType" />
                                </td>

                                <td>
                                    <xsl:value-of select="$surfaceType" />
                                </td>

                                <td>
                                    <xsl:value-of select="floor($totalMinutes div 60)" />
                                    <!-- Floor :Returns the largest integer that is not greater than the argument. Therefore return the number of hours -->
                                    <xsl:text> hours and </xsl:text>
                                    <xsl:value-of select="$totalMinutes mod 60" />
                                    <!-- return the remaining minutes-->
                                    <xsl:text> minutes</xsl:text>
                                </td>
                            </tr>

                        </xsl:for-each>
                    </tbody>
                </table>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>