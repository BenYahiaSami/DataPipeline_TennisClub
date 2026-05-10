<?xml version="1.0" encoding="UTF-8"?>
<!--
  ================================================================
  FILE         : scenario3.xsl
  PROJECT      : A25 - Data Pipeline - RG Tennis Club
  SCENARIO 3   : New member registrations over the last 5 years
  ================================================================

  OVERVIEW
  - - - - 
  This stylesheet produces an HTML page showing the number of new
  members registered each year over a 5-year window (2021 to 2025),
  presented in three complementary formats:

    1. SUMMARY BOXES    one counter box per year, peak year highlighted
    2. DATA TABLE       year | count | percentage of 5-year total | mini bar
    3. SVG BAR CHART    vertical bars, proportional to member count,
                        peak bar colored gold
    4. MEMBERSCHIPS     for each year, the list of members who joined
                        that year (ID + full name)

  ================================================================
  INPUT   : tennis_club.xml  (root element TENNIS_CLUB)
  OUTPUT  : scenario3_output.html
  ================================================================
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>

  <xsl:param name="currentYear" select="'2025'"/>

  <xsl:variable name="y5" select="string(number($currentYear))"/>
  <xsl:variable name="y4" select="string(number($currentYear) - 1)"/>
  <xsl:variable name="y3" select="string(number($currentYear) - 2)"/>
  <xsl:variable name="y2" select="string(number($currentYear) - 3)"/>
  <xsl:variable name="y1" select="string(number($currentYear) - 4)"/>

  <!--
    Per-year counts: for each year $yN, count MEMBER nodes whose
    first MEMBERSHIP InscriptionDate starts with that year string.
    substring(..., 1, 4) extracts the YYYY part.
  -->
  <xsl:variable name="c1"
    select="count(/TENNIS_CLUB/MEMBERS/MEMBER[
      substring(MEMBERSHIPS/MEMBERSHIP[1]/INSCRIPTIONDATE,1,4) = $y1])"/>
  <xsl:variable name="c2"
    select="count(/TENNIS_CLUB/MEMBERS/MEMBER[
      substring(MEMBERSHIPS/MEMBERSHIP[1]/INSCRIPTIONDATE,1,4) = $y2])"/>
  <xsl:variable name="c3"
    select="count(/TENNIS_CLUB/MEMBERS/MEMBER[
      substring(MEMBERSHIPS/MEMBERSHIP[1]/INSCRIPTIONDATE,1,4) = $y3])"/>
  <xsl:variable name="c4"
    select="count(/TENNIS_CLUB/MEMBERS/MEMBER[
      substring(MEMBERSHIPS/MEMBERSHIP[1]/INSCRIPTIONDATE,1,4) = $y4])"/>
  <xsl:variable name="c5"
    select="count(/TENNIS_CLUB/MEMBERS/MEMBER[
      substring(MEMBERSHIPS/MEMBERSHIP[1]/INSCRIPTIONDATE,1,4) = $y5])"/>


  <!-- Total registrations across the 5-year period (sum of c1..c5). -->
  <xsl:variable name="total5" select="$c1 + $c2 + $c3 + $c4 + $c5"/>


  
  <xsl:variable name="maxCount">
    <xsl:choose>
      <xsl:when test="$c1 &gt;= $c2 and $c1 &gt;= $c3 and $c1 &gt;= $c4 and $c1 &gt;= $c5">
        <xsl:value-of select="$c1"/>
      </xsl:when>
      <xsl:when test="$c2 &gt;= $c1 and $c2 &gt;= $c3 and $c2 &gt;= $c4 and $c2 &gt;= $c5">
        <xsl:value-of select="$c2"/>
      </xsl:when>
      <xsl:when test="$c3 &gt;= $c1 and $c3 &gt;= $c2 and $c3 &gt;= $c4 and $c3 &gt;= $c5">
        <xsl:value-of select="$c3"/>
      </xsl:when>
      <xsl:when test="$c4 &gt;= $c1 and $c4 &gt;= $c2 and $c4 &gt;= $c3 and $c4 &gt;= $c5">
        <xsl:value-of select="$c4"/>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$c5"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  
  <xsl:template match="/">
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <title>Members per Year</title>
        <style>
          body { font-family: system-ui, Arial, sans-serif; margin: 24px; } h1 { margin: 0 0 8px; } h2 { margin: 24px 0 10px; font-size: 1.05em; color: #333; border-bottom: 1px solid #e3e3e3; padding-bottom: 6px; } .hint { color:#555; margin: 0 0 20px; } table { border-collapse: collapse; width: 100%; margin-bottom: 28px; } th, td { border: 1px solid #e3e3e3; padding: 8px 10px; vertical-align: top; } th { background: #f7f7f8; text-align: left; } tbody tr:nth-child(even) { background: #fafafa; } .muted { color:#666; font-size: 0.9em; } code { background:#f3f3f6; padding:1px 4px; border-radius:4px; } .summary { display:flex; gap:14px; flex-wrap:wrap; margin-bottom:28px; } .summary-box { flex:1; min-width:110px; border:1px solid #e3e3e3; border-radius:8px; padding:12px 16px; text-align:center; background:#fafafa; } .summary-box .val { font-size:2em; font-weight:700; color:#333; } .summary-box .lbl { font-size:0.8em; color:#666; margin-top:2px; } .best-val { color: #b45309; } .bar-bg { background:#e3e3e3; border-radius:4px; height:8px; width:100%; overflow:hidden; } .bar-fill { background:#555; height:8px; border-radius:4px; } .bar-fill-best { background:#b45309; } .chips { display:flex; flex-wrap:wrap; gap:6px; margin-top:4px; } .chip { display:inline-block; padding:3px 10px; border:1px solid #ccc; border-radius:14px; font-size:0.82em; background:#f7f7f8; } .chip code { background:none; padding:0; font-weight:600; color:#555; } .year-block { margin-bottom:18px; } .empty { color:#999; font-style:italic; }
        </style>
      </head>
      <body>

        <h1> New Members per Year</h1>
        <p class="hint">
          Period <xsl:value-of select="$y1"/>–<xsl:value-of select="$y5"/> |
          Total over 5 years: <code><xsl:value-of select="$total5"/></code> members
        </p>

        <div class="summary">
          <div class="summary-box">
            <div class="val"><xsl:value-of select="$total5"/></div>
            <div class="lbl">Total (5 yrs)</div>
          </div>
          <xsl:call-template name="summaryBox">
            <xsl:with-param name="year"  select="$y1"/>
            <xsl:with-param name="count" select="$c1"/>
            <xsl:with-param name="max"   select="$maxCount"/>
          </xsl:call-template>
          <xsl:call-template name="summaryBox">
            <xsl:with-param name="year"  select="$y2"/>
            <xsl:with-param name="count" select="$c2"/>
            <xsl:with-param name="max"   select="$maxCount"/>
          </xsl:call-template>
          <xsl:call-template name="summaryBox">
            <xsl:with-param name="year"  select="$y3"/>
            <xsl:with-param name="count" select="$c3"/>
            <xsl:with-param name="max"   select="$maxCount"/>
          </xsl:call-template>
          <xsl:call-template name="summaryBox">
            <xsl:with-param name="year"  select="$y4"/>
            <xsl:with-param name="count" select="$c4"/>
            <xsl:with-param name="max"   select="$maxCount"/>
          </xsl:call-template>
          <xsl:call-template name="summaryBox">
            <xsl:with-param name="year"  select="$y5"/>
            <xsl:with-param name="count" select="$c5"/>
            <xsl:with-param name="max"   select="$maxCount"/>
          </xsl:call-template>
        </div>

        <h2>Summary Table</h2>
        <table>
          <thead>
            <tr>
              <th>Year</th>
              <th>New Members</th>
              <th>% of 5-year total</th>
              <th>Proportion</th>
            </tr>
          </thead>
          <tbody>
            <xsl:call-template name="tableRow">
              <xsl:with-param name="year"  select="$y1"/>
              <xsl:with-param name="count" select="$c1"/>
              <xsl:with-param name="max"   select="$maxCount"/>
              <xsl:with-param name="total" select="$total5"/>
            </xsl:call-template>
            <xsl:call-template name="tableRow">
              <xsl:with-param name="year"  select="$y2"/>
              <xsl:with-param name="count" select="$c2"/>
              <xsl:with-param name="max"   select="$maxCount"/>
              <xsl:with-param name="total" select="$total5"/>
            </xsl:call-template>
            <xsl:call-template name="tableRow">
              <xsl:with-param name="year"  select="$y3"/>
              <xsl:with-param name="count" select="$c3"/>
              <xsl:with-param name="max"   select="$maxCount"/>
              <xsl:with-param name="total" select="$total5"/>
            </xsl:call-template>
            <xsl:call-template name="tableRow">
              <xsl:with-param name="year"  select="$y4"/>
              <xsl:with-param name="count" select="$c4"/>
              <xsl:with-param name="max"   select="$maxCount"/>
              <xsl:with-param name="total" select="$total5"/>
            </xsl:call-template>
            <xsl:call-template name="tableRow">
              <xsl:with-param name="year"  select="$y5"/>
              <xsl:with-param name="count" select="$c5"/>
              <xsl:with-param name="max"   select="$maxCount"/>
              <xsl:with-param name="total" select="$total5"/>
            </xsl:call-template>
          </tbody>
        </table>

        <h2> Bar Chart</h2>
        <svg xmlns="http://www.w3.org/2000/svg" width="560" height="200"
             style="border:1px solid #e3e3e3; border-radius:6px; background:#fafafa; display:block; margin-bottom:28px;">

          <line x1="80" y1="20" x2="80" y2="160" stroke="#e3e3e3" stroke-width="1"/>
          <line x1="80" y1="160" x2="540" y2="160" stroke="#e3e3e3" stroke-width="1"/>

          <xsl:call-template name="svgBar">
            <xsl:with-param name="year"  select="$y1"/>
            <xsl:with-param name="count" select="$c1"/>
            <xsl:with-param name="max"   select="$maxCount"/>
            <xsl:with-param name="xPos"  select="90"/>
          </xsl:call-template>
          <xsl:call-template name="svgBar">
            <xsl:with-param name="year"  select="$y2"/>
            <xsl:with-param name="count" select="$c2"/>
            <xsl:with-param name="max"   select="$maxCount"/>
            <xsl:with-param name="xPos"  select="170"/>
          </xsl:call-template>
          <xsl:call-template name="svgBar">
            <xsl:with-param name="year"  select="$y3"/>
            <xsl:with-param name="count" select="$c3"/>
            <xsl:with-param name="max"   select="$maxCount"/>
            <xsl:with-param name="xPos"  select="250"/>
          </xsl:call-template>
          <xsl:call-template name="svgBar">
            <xsl:with-param name="year"  select="$y4"/>
            <xsl:with-param name="count" select="$c4"/>
            <xsl:with-param name="max"   select="$maxCount"/>
            <xsl:with-param name="xPos"  select="330"/>
            <xsl:with-param name="isBest" select="$c4 = $maxCount"/>
          </xsl:call-template>
          <xsl:call-template name="svgBar">
            <xsl:with-param name="year"  select="$y5"/>
            <xsl:with-param name="count" select="$c5"/>
            <xsl:with-param name="max"   select="$maxCount"/>
            <xsl:with-param name="xPos"  select="410"/>
          </xsl:call-template>

          <text x="14" y="95" font-size="11" fill="#666"
                transform="rotate(-90,14,95)" text-anchor="middle">Members</text>
        </svg>

        <h2> Members Detail by Year</h2>
        <xsl:call-template name="yearDetail">
          <xsl:with-param name="year" select="$y1"/>
        </xsl:call-template>
        <xsl:call-template name="yearDetail">
          <xsl:with-param name="year" select="$y2"/>
        </xsl:call-template>
        <xsl:call-template name="yearDetail">
          <xsl:with-param name="year" select="$y3"/>
        </xsl:call-template>
        <xsl:call-template name="yearDetail">
          <xsl:with-param name="year" select="$y4"/>
        </xsl:call-template>
        <xsl:call-template name="yearDetail">
          <xsl:with-param name="year" select="$y5"/>
        </xsl:call-template>

        <p class="muted">RG Tennis Club | Period <xsl:value-of select="$y1"/>–<xsl:value-of select="$y5"/></p>

      </body>
    </html>
  </xsl:template>

 
  <xsl:template name="summaryBox">
    <xsl:param name="year"/>
    <xsl:param name="count"/>
    <xsl:param name="max"/>
    <div class="summary-box">
      <div>
        <xsl:attribute name="class">
          <xsl:choose>
            <xsl:when test="$count = $max">val best-val</xsl:when>
            <xsl:otherwise>val</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:value-of select="$count"/>
        <xsl:if test="$count = $max"> </xsl:if>
      </div>
      <div class="lbl"><xsl:value-of select="$year"/></div>
    </div>
  </xsl:template>

  <xsl:template name="tableRow">
    <xsl:param name="year"/>
    <xsl:param name="count"/>
    <xsl:param name="max"/>
    <xsl:param name="total"/>

    <xsl:variable name="pct">
      <xsl:choose>
        <xsl:when test="$total &gt; 0">
          <xsl:value-of select="round($count div $total * 100)"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="barW">
      <xsl:choose>
        <xsl:when test="$max &gt; 0">
          <xsl:value-of select="round($count div $max * 80)"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="fillClass">
      <xsl:choose>
        <xsl:when test="$count = $max">bar-fill bar-fill-best</xsl:when>
        <xsl:otherwise>bar-fill</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <tr>
      <td>
        <strong><xsl:value-of select="$year"/></strong>
        <xsl:if test="$count = $max"> </xsl:if>
      </td>
      <td><xsl:value-of select="$count"/></td>
      <td class="muted"><xsl:value-of select="$pct"/>%</td>
      <td style="min-width:100px; vertical-align:middle;">
        <div class="bar-bg">
          <div class="{$fillClass}" style="{concat('width:', $barW, 'px')}"/>
        </div>
      </td>
    </tr>
  </xsl:template>

  <!--
    ================================================================
    NAMED TEMPLATE : svgBar
    Renders one vertical bar group (background + fill + labels).
    Params:
      $year   string   year label (X-axis)
      $count  number   member count (determines bar height)
      $max    number   peak count (normalizes height)
      $xPos   number   horizontal pixel position of the bar group
      $isBest boolean  if true, colors the bar gold (#b45309)
    ================================================================
  -->
  <xsl:template name="svgBar">
    <xsl:param name="year"/>
    <xsl:param name="count"/>
    <xsl:param name="max"/>
    <xsl:param name="xPos"/>
    <xsl:param name="isBest" select="false()"/>

    <xsl:variable name="maxH" select="120"/>
    <xsl:variable name="barH">
      <xsl:choose>
        <xsl:when test="$max &gt; 0">
          <xsl:value-of select="round($count div $max * $maxH)"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="barColor">
      <xsl:choose>
        <xsl:when test="$isBest">#b45309</xsl:when>
        <xsl:otherwise>#555</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <rect x="{$xPos}" y="20" width="55" height="{$maxH}"
          fill="#e3e3e3" rx="3"/>

    <xsl:if test="$count &gt; 0">
      <rect x="{$xPos}" y="{160 - $barH}" width="55" height="{$barH}"
            fill="{$barColor}" rx="3"/>
    </xsl:if>

    <text x="{$xPos + 27}" y="{160 - $barH - 4}"
          text-anchor="middle" font-size="11" fill="#333" font-weight="600">
      <xsl:value-of select="$count"/>
    </text>

    <text x="{$xPos + 27}" y="176"
          text-anchor="middle" font-size="11" fill="#666">
      <xsl:value-of select="$year"/>
    </text>
  </xsl:template>

  <xsl:template name="yearDetail">
    <xsl:param name="year"/>

    <xsl:variable name="members"
      select="/TENNIS_CLUB/MEMBERS/MEMBER[
        substring(MEMBERSHIPS/MEMBERSHIP[1]/INSCRIPTIONDATE,1,4) = $year]"/>

    <div class="year-block">
      <strong>
        <xsl:value-of select="$year"/> :
        <xsl:value-of select="count($members)"/> new member(s)
      </strong>
      <div class="chips">
        <xsl:choose>
          <xsl:when test="count($members) &gt; 0">
            <xsl:apply-templates select="$members" mode="chip">
              <xsl:sort select="INFORMATION/LAST_NAME"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <span class="empty">No new members this year.</span>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="MEMBER" mode="chip">
    <span class="chip">
      <code>#<xsl:value-of select="@Id"/></code>
      <xsl:text> </xsl:text>
      <xsl:value-of select="INFORMATION/FIRST_NAME"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="INFORMATION/LAST_NAME"/>
    </span>
  </xsl:template>

</xsl:stylesheet>
