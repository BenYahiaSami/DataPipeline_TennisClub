<?xml version="1.0" encoding="UTF-8"?>
<!--

  This stylesheet queries the tennis club XML database and produces
  an HTML page listing all members who simultaneously satisfy
  the following two conditions:

    (A) SENIORITY >= 3 YEARS
        The member has at least one MEMBERSHIP whose INSCRIPTIONDATE
        is less than or equal to the date threshold $threshold.
        $threshold = $today minus 3 years.

    (B) TOURNAMENT WINNER
        The member full name (FIRST_NAME + ' ' + LAST_NAME) matches
        the WINNER element of at least one TOURNAMENT in the database.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="xml" encoding="UTF-8" indent="yes" doctype-system="about:legacy-compat"/>
  <xsl:param name="today" select="'2026-04-27'"/>
  <xsl:param name="threshold" select="'2023-04-27'"/>

  <!-- XSLT key: index TOURNAMENT nodes by WINNER element value for fast lookup. -->
  <xsl:key name="tournamentByWINNER" match="TOURNAMENT" use="WINNER"/>
  <xsl:template match="/">
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <title>Senior WINNERs</title>
        <style> 
          body { font-family: system-ui, Arial, sans-serif; margin: 24px; } 
          h1 { margin: 0 0 8px; } 
          .hint { color:#555; margin: 0 0 16px; } 
          table { border-collapse: collapse; width: 100%; } 
          th, td { border: 1px solid #e3e3e3; padding: 8px 10px; vertical-align: top; } 
          th { background: #f7f7f8; text-align: left; } 
          tbody tr:nth-child(even) { background: #fafafa; } 
          .muted { color:#666; font-size: 0.9em; } 
          .tags .tag { display:inline-block; padding:2px 6px; border:1px solid #ccc; border-radius:6px; margin-right:4px; font-size:0.85em; } 
          .list { margin: 4px 0 0 18px; } 
          code { background:#f3f3f6; padding:1px 4px; border-radius:4px; } 
        </style>
      </head>
      <body>
        <h1> Senior WINNERs</h1>
        <div class="hint">
Members with seniority ≥ 3 years
          <strong>AND</strong>
who won at least one tournament  |  Reference date:
          <code>
            <xsl:value-of select="$today"/>
          </code>
 |  Threshold:
          <code>
            <xsl:value-of select="$threshold"/>
          </code>
        </div>
        <!-- 
          Build the list of qualifying MEMBERs :
            (A) has a MEMBERSHIP with INSCRIPTIONDATE <= threshold
            (B) full name (FIRST_NAME + LAST_NAME) matches a WINNER element
         -->

        <xsl:variable name="qualifyingMembers" select="/TENNIS_CLUB/MEMBERS/MEMBER[ MEMBERSHIPS/MEMBERSHIP[ number(translate(INSCRIPTIONDATE,'-','')) &lt;= number(translate($threshold,'-','')) ] ]"/>

        <xsl:variable name="hitMarkers">

          <xsl:for-each select="$qualifyingMembers">
            <xsl:variable name="fullName" select="concat(INFORMATION/FIRST_NAME,' ',INFORMATION/LAST_NAME)"/>
            <xsl:if test="count(/TENNIS_CLUB/TOURNAMENTS/TOURNAMENT[WINNER=$fullName]) > 0">
              <xsl:text>X</xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="hitCount" select="string-length($hitMarkers)"/>
        <xsl:choose>
          <xsl:when test="$hitCount > 0">
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Member</th>
                  <th>Gender</th>
                  <th>Contact</th>
                  <th>Member since</th>
                  <th>Seniority</th>
                  <th>Level(s)</th>
                  <th>Tournaments won</th>
                </tr>
              </thead>
              <tbody>

                <xsl:for-each select="$qualifyingMembers">
                  <!--  Sort by inscription date ascending  -->
                  <xsl:sort select="MEMBERSHIPS/MEMBERSHIP[1]/INSCRIPTIONDATE" order="ascending"/>
                  <xsl:variable name="fullName" select="concat(INFORMATION/FIRST_NAME,' ',INFORMATION/LAST_NAME)"/>
                  <xsl:variable name="wonTournaments" select="/TENNIS_CLUB/TOURNAMENTS/TOURNAMENT[WINNER=$fullName]"/>
                  <!--  Only render if this member actually won something  -->
                  <xsl:if test="count($wonTournaments) > 0">
                    <!--  Earliest qualifying inscription date  -->

                    <!--
                    Find the earliest INSCRIPTIONDATE that is still within the
                    seniority window (<= $threshold). Sort eligible MEMBERSHIP
                    nodes ascending and pick position()=1. Used to display the
                    "Member since" date and to compute seniority in years.
                    -->
                    <xsl:variable name="earliestDate">
                      <xsl:for-each select="MEMBERSHIPS/MEMBERSHIP[ number(translate(INSCRIPTIONDATE,'-','')) &lt;= number(translate($threshold,'-',''))]">
                        <xsl:sort select="INSCRIPTIONDATE" order="ascending"/>
                        <xsl:if test="position()=1">
                          <xsl:value-of select="INSCRIPTIONDATE"/>
                        </xsl:if>
                      </xsl:for-each>
                    </xsl:variable>
                    <!--  Seniority in full years (year subtraction)  -->

                    <!-- Approximate seniority: current year minus year of earliest eligible membership. -->
                    <xsl:variable name="seniorityYears" select="number(substring($today,1,4)) - number(substring($earliestDate,1,4))"/>
                    <tr>
                      <!--  ID  -->
                      <td>
                        <code>
                          <xsl:value-of select="@Id"/>
                        </code>
                      </td>
                      <!--  Name + birth date  -->
                      <td>
                        <div>
                          <strong>
                            <xsl:value-of select="INFORMATION/FIRST_NAME"/>
                            <xsl:text></xsl:text>
                            <xsl:value-of select="INFORMATION/LAST_NAME"/>
                          </strong>
                        </div>
                        <div class="muted">
Born:
                          <xsl:value-of select="INFORMATION/BIRTH_DATE"/>
                        </div>
                      </td>
                      <!--  Gender  -->
                      <td>
                        <xsl:value-of select="INFORMATION/SEXE"/>
                      </td>
                      <!--  Contact  -->
                      <td>
                        <div>
                          <xsl:value-of select="CONTACT/EMAIL"/>
                        </div>
                        <div class="muted">
                          <xsl:value-of select="CONTACT/PHONE_NUMBER"/>
                        </div>
                      </td>
                      <!--  First inscription date  -->
                      <td>
                        <xsl:value-of select="$earliestDate"/>
                      </td>
                      <!--  Seniority as a tag  -->
                      <td>
                        <div class="tags">
                          <span class="tag">
≥
                            <xsl:value-of select="$seniorityYears"/>
yrs
                          </span>
                        </div>
                      </td>
                      <!--  All membership levels (distinct tags)  -->
                      <td>
                        <div class="tags">
                          <xsl:for-each select="MEMBERSHIPS/MEMBERSHIP">
                            <span class="tag">
                              <xsl:value-of select="MEMBERLEVEL"/>
                            </span>
                          </xsl:for-each>
                        </div>
                      </td>
                      <!--  Won tournaments list  -->
                      <td>
                        <ul class="list">
                          <xsl:for-each select="$wonTournaments">
                            <xsl:sort select="substring(DATE_HOUR_BEGIN,1,4)" order="ascending"/>
                            <li>
                              <strong>
                                <xsl:value-of select="NAME"/>
                              </strong>
                              <xsl:text></xsl:text>
                              <span class="muted">
(
                                <xsl:value-of select="substring(DATE_HOUR_BEGIN,1,10)"/>
)
                              </span>
                              <br/>
                              <span class="muted">
Level:
                                <xsl:value-of select="LEVEL"/>
—  Prize:
                                <xsl:value-of select="PRICE"/>
€
                              </span>
                            </li>
                          </xsl:for-each>
                        </ul>
                      </td>
                    </tr>
                  </xsl:if>
                </xsl:for-each>
              </tbody>
            </table>
          </xsl:when>
          <xsl:otherwise>
            <p>No member meets both criteria (seniority ≥ 3 years AND tournament winner).</p>
          </xsl:otherwise>
        </xsl:choose>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>