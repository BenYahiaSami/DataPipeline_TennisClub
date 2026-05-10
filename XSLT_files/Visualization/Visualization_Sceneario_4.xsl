<?xml version="1.0" encoding="UTF-8"?>
<!-- Sum of training hours for each coach -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="UTF-8" />

  <!--Use
  of a template to sum the duration of training sessions as the sum function do not work unless  used
  on an existing node
	The template will get the duration of a training sessions, then call itself recursively While
  incrementing the accumulator value, which will contain the total minutes at the end
	-->
  <xsl:template name="sumMinutes">
    <xsl:param name="sessions" />
    <xsl:param name="accumulator" select="0" /> <!-- the sum variable that will get the total minutes  -->
    <xsl:choose>
      <xsl:when test="$sessions"> <!-- is sessions empty ? if it is, the recursivity is over -->
        <xsl:variable name="current" select="$sessions[1]" /> <!-- We take the first value of the sessions-->

        <!-- Computation : (hoursEnd * 60 + minutesEnd) - (hoursBegin * 60 + minutesBegin) 
        Resolve the problem where minuteEnd is inferior to minuteBegin. Get the total duration in
        minutes-->
        <xsl:variable
          name="duration"
          select="( number(substring($current/DATE_HOUR_END,12,2))   * 60 + number(substring($current/DATE_HOUR_END,15,2))   )
                - ( number(substring($current/DATE_HOUR_BEGIN,12,2)) * 60 + number(substring($current/DATE_HOUR_BEGIN,15,2)) )" />
				
        <xsl:call-template
          name="sumMinutes">
          <xsl:with-param name="sessions" select="$sessions[position() > 1]" /> <!-- We removes the sessions we already computed which is the first one-->
          <xsl:with-param name="accumulator" select="$accumulator + $duration" /> <!--  accumulator is incremented with each recursive call-->
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
        <title>Training time for each sessions and the coach in charge</title>
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
        <h1>Below the coach information followed by their training duration:</h1>
        <table>
          <thead>
            <tr>
              <th>Last Name</th>
              <th>First Name</th>
              <th>Id</th>
              <th>Total Duration</th>
            </tr>
          </thead>


          <tbody>
            <!-- Iterate once per unique coach -->
            <xsl:for-each
              select="TENNIS_CLUB/TRAINING_SESSIONS/TRAINING_SESSION[not(COACHID=preceding-sibling::TRAINING_SESSION/COACHID)]">
              <xsl:sort select="COACHID"/> <!-- Sort by coachID-->

              <xsl:variable name="coachId" select="COACHID" />
              <xsl:variable name="coachLastName"
                select="/TENNIS_CLUB/COACHS/COACH[@Id = $coachId]/INFORMATION/LAST_NAME" />
              <xsl:variable
                name="coachFirstName"
                select="/TENNIS_CLUB/COACHS/COACH[@Id = $coachId]/INFORMATION/FIRST_NAME" />

            <xsl:variable
                name="totalMinutes">
                <xsl:call-template name="sumMinutes">
                  <xsl:with-param name="sessions"
                    select="/TENNIS_CLUB/TRAINING_SESSIONS/TRAINING_SESSION[COACHID = $coachId]" />
                </xsl:call-template>
            </xsl:variable>
              <tr>

                <td>
                  <xsl:value-of select="$coachLastName" />
                </td>

                <td>
                  <xsl:value-of select="$coachFirstName" />
                </td>

                <td>
                  <xsl:value-of select="$coachId" />
                </td>

                <td>
                  <xsl:value-of select="floor($totalMinutes div 60)" /> <!-- Floor :Returns the largest integer that is not greater than the argument. Therefore return the number of hours -->
                  <xsl:text> hours and </xsl:text>
                  <xsl:value-of select="$totalMinutes mod 60" /> <!-- return the remaining minutes-->
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