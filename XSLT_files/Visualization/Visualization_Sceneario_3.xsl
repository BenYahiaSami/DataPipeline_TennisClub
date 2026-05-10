<?xml version="1.0" encoding="UTF-8"?>
<!--


  This stylesheet reads the XML database and produces an HTML page
  that classifies every club member into one of three age categories:

    MINOR   : age strictly below 18 years old
              BIRTH_DATE  >  $minorCutoff   ('2007-04-25')

    ADULT   : 18 years old <= age < 60 years old
              $seniorCutoff <=  BIRTH_DATE <=  $minorCutoff

    SENIOR  : age 60 years old or above
              BIRTH_DATE  <  $seniorCutoff   ('1965-04-26')

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
  <xsl:param name="today" select="'2025-04-25'"/>
  <xsl:variable name="currentYear" select="number(substring($today,1,4))"/>
  <xsl:variable name="currentMonthDay" select="substring($today,6)"/>
  <xsl:variable name="minorCutoff" select="concat(number(substring($today,1,4)) - 18, substring($today,5))"/>
  <xsl:variable name="seniorCutoff" select="concat(number(substring($today,1,4)) - 60, substring($today,5))"/>
  <xsl:template match="/">
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <title>Age Categories</title>
        <style> body { 
  font-family: system-ui, Arial, sans-serif; margin: 24px; } 
  h1 { margin: 0 0 8px; } 
  h2 { margin: 24px 0 8px; font-size: 1.1em; color: #333; border-bottom: 1px solid #e3e3e3; padding-bottom: 6px; } 
  .hint { color:#555; margin: 0 0 16px; } table { border-collapse: collapse; width: 100%; margin-bottom: 32px; }
  th, td { border: 1px solid #e3e3e3; padding: 8px 10px; vertical-align: top; }
  th { background: #f7f7f8; text-align: left; }
  tbody tr:nth-child(even) { background: #fafafa; } 
  .muted { color:#666; font-size: 0.9em; } 
  code { background:#f3f3f6; padding:1px 4px; border-radius:4px; } 
  .badge { display: inline-block; padding: 2px 8px; border-radius: 6px; font-size: 0.82em; font-weight: 600; border: 1px solid; } 
  .badge-minor { background:#e0f2fe; border-color:#38bdf8; color:#0369a1; } 
  .badge-adult { background:#dcfce7; border-color:#22c55e; color:#15803d; } 
  .badge-senior { background:#ffedd5; border-color:#fb923c; color:#c2410c; } 
  .summary { display:flex; gap:16px; flex-wrap:wrap; margin-bottom:28px; } 
  .summary-box { flex:1; min-width:120px; border:1px solid #e3e3e3; border-radius:8px; padding:14px 18px; text-align:center; background:#fafafa; } 
  .summary-box .val { font-size:2.2em; font-weight:700; } 
  .summary-box .lbl { font-size:0.82em; color:#666; margin-top:2px; } 
  .val-minor { color:#0369a1; }
  .val-adult { color:#15803d; } 
  .val-senior { color:#c2410c; } 
  .val-total { color:#333; } 
  .empty { color:#999; font-style:italic; padding:12px 0; } </style>
      </head>
      <body>
        <h1>Member Age Categories</h1>
        <p class="hint">
          <xsl:value-of select="/TENNIS_CLUB/@ClubName"/>
— Reference date:
          <code>
            <xsl:value-of select="$today"/>
          </code>
        </p>

        <xsl:variable name="minors" select="/TENNIS_CLUB/MEMBERS/MEMBER[ number(translate(INFORMATION/BIRTH_DATE,'-','')) > number(translate($minorCutoff,'-',''))]"/>
        <xsl:variable name="seniors" select="/TENNIS_CLUB/MEMBERS/MEMBER[ number(translate(INFORMATION/BIRTH_DATE,'-','')) &lt; number(translate($seniorCutoff,'-',''))]"/>
        <xsl:variable name="adults" select="/TENNIS_CLUB/MEMBERS/MEMBER[ number(translate(INFORMATION/BIRTH_DATE,'-','')) &lt;= number(translate($minorCutoff,'-','')) and number(translate(INFORMATION/BIRTH_DATE,'-','')) >= number(translate($seniorCutoff,'-',''))]"/>
        <div class="summary">
          <div class="summary-box">
            <div class="val val-total">
              <xsl:value-of select="count(/TENNIS_CLUB/MEMBERS/MEMBER)"/>
            </div>
            <div class="lbl">Total Members</div>
          </div>
          <div class="summary-box">
            <div class="val val-minor">
              <xsl:value-of select="count($minors)"/>
            </div>
            <div class="lbl">Minors (age &lt; 18)</div>
          </div>
          <div class="summary-box">
            <div class="val val-adult">
              <xsl:value-of select="count($adults)"/>
            </div>
            <div class="lbl">Adults (18 ≤ age &lt; 60)</div>
          </div>
          <div class="summary-box">
            <div class="val val-senior">
              <xsl:value-of select="count($seniors)"/>
            </div>
            <div class="lbl">Seniors (age ≥ 60)</div>
          </div>
        </div>
        <!--  ── MINORS ──  -->
        <h2>
 Minors : Age &lt; 18 (
          <xsl:value-of select="count($minors)"/>
member(s))
        </h2>
        <xsl:choose>
          <xsl:when test="count($minors) > 0">
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>First Name</th>
                  <th>Last Name</th>
                  <th>Gender</th>
                  <th>Date of Birth</th>
                  <th>Age</th>
                  <th>Level</th>
                </tr>
              </thead>
              <tbody>
                <xsl:apply-templates select="$minors" mode="row">
                  <xsl:with-param name="category" select="'minor'"/>
                  <xsl:sort select="INFORMATION/BIRTH_DATE" order="descending"/>
                </xsl:apply-templates>
              </tbody>
            </table>
          </xsl:when>
          <xsl:otherwise>
            <p class="empty">No minors registered.</p>
          </xsl:otherwise>
        </xsl:choose>
        <!--  ── ADULTS ──  -->
        <h2>
 Adults : 18 ≤ Age &lt; 60 (
          <xsl:value-of select="count($adults)"/>
member(s))
        </h2>
        <xsl:choose>
          <xsl:when test="count($adults) > 0">
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>First Name</th>
                  <th>Last Name</th>
                  <th>Gender</th>
                  <th>Date of Birth</th>
                  <th>Age</th>
                  <th>Level</th>
                </tr>
              </thead>
              <tbody>
                <xsl:apply-templates select="$adults" mode="row">
                  <xsl:with-param name="category" select="'adult'"/>
                  <xsl:sort select="INFORMATION/BIRTH_DATE" order="descending"/>
                </xsl:apply-templates>
              </tbody>
            </table>
          </xsl:when>
          <xsl:otherwise>
            <p class="empty">No adults registered.</p>
          </xsl:otherwise>
        </xsl:choose>
        <!--  ── SENIORS ──  -->
        <h2>
 Seniors : Age ≥ 60 (
          <xsl:value-of select="count($seniors)"/>
member(s))
        </h2>
        <xsl:choose>
          <xsl:when test="count($seniors) > 0">
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>First Name</th>
                  <th>Last Name</th>
                  <th>Gender</th>
                  <th>Date of Birth</th>
                  <th>Age</th>
                  <th>Level</th>
                </tr>
              </thead>
              <tbody>
                <xsl:apply-templates select="$seniors" mode="row">
                  <xsl:with-param name="category" select="'senior'"/>
                  <xsl:sort select="INFORMATION/BIRTH_DATE" order="descending"/>
                </xsl:apply-templates>
              </tbody>
            </table>
          </xsl:when>
          <xsl:otherwise>
            <p class="empty">No seniors registered.</p>
          </xsl:otherwise>
        </xsl:choose>
        <p class="muted">
RG Tennis Club | Generated on
          <xsl:value-of select="$today"/>
        </p>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="MEMBER" mode="row">
    <xsl:param name="category"/>
    <xsl:variable name="birthYear" select="number(substring(INFORMATION/BIRTH_DATE,1,4))"/>
    <xsl:variable name="birthMonthDay" select="substring(INFORMATION/BIRTH_DATE,6)"/>
    <!-- Raw age: year difference before birthday-offset correction. -->
    <xsl:variable name="rawAge" select="$currentYear - $birthYear"/>
    <xsl:variable name="age">
      <xsl:choose>
        <xsl:when test="$birthMonthDay > $currentMonthDay">
          <xsl:value-of select="$rawAge - 1"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$rawAge"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="badgeClass">
      <xsl:choose>
        <xsl:when test="$category = 'minor'">badge badge-minor</xsl:when>
        <xsl:when test="$category = 'senior'">badge badge-senior</xsl:when>
        <xsl:otherwise>badge badge-adult</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!--
  Current membership level: sort all MEMBERSHIP nodes by END_DATE
  descending and pick position()=1 (the most recently active one).
-->
    <xsl:variable name="level">
      <xsl:for-each select="MEMBERSHIPS/MEMBERSHIP">
        <xsl:sort select="END_DATE" order="descending"/>
        <xsl:if test="position() = 1">
          <xsl:value-of select="MEMBERLEVEL"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <tr>
      <td>
        <code>
          <xsl:value-of select="@Id"/>
        </code>
      </td>
      <td>
        <xsl:value-of select="INFORMATION/FIRST_NAME"/>
      </td>
      <td>
        <xsl:value-of select="INFORMATION/LAST_NAME"/>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="INFORMATION/SEXE = 'Male'">♂ Homme</xsl:when>
          <xsl:otherwise>♀ Femme</xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:value-of select="INFORMATION/BIRTH_DATE"/>
      </td>
      <td>
        <span class="{$badgeClass}">
          <xsl:value-of select="$age"/>
yrs
        </span>
      </td>
      <td>
        <xsl:value-of select="$level"/>
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>