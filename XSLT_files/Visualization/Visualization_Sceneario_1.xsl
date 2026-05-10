<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>
  <xsl:key name="players-by-name" match = "TENNIS_CLUB/BOOKINGS/BOOKING/PLAYERS/PLAYER[not(@id)]" use = "concat(LAST_NAME, ' ',FIRST_NAME)"/> <!-- key here allow to group every players without an ID by their LASTNAME AND FIRSTNAME. Will be used later to prevent duplicata of the same members in the result-->

  <xsl:template match="/">

    <html>
      <head>
        <title>New members after playing as guests</title>
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

        <h1>The guests who became members are:</h1>

        <table>
          <thead>
            <tr>
              <th>Last Name</th>
              <th>First Name</th>
              <th>Id</th>
            </tr>
          </thead>


          <xsl:for-each select="TENNIS_CLUB/BOOKINGS/BOOKING/PLAYERS/PLAYER[not(@Id) and
          generate-id() = generate-id(key('players-by-name', concat(LAST_NAME, ' ', FIRST_NAME))[1])]">
          <!-- Get every player whithout Id attribute. generate-id allow to use the node Id. Thanks to that,We check if we are working with the first occurence of LASTNAME AND FIRSTNAME to prevent duplicata of the same member   -->
            
            <xsl:variable
              name="ln" select="LAST_NAME" />
            <xsl:variable name="fn" select="FIRST_NAME" />
            
            
            <xsl:if
              test="/TENNIS_CLUB/MEMBERS/MEMBER[INFORMATION/LAST_NAME = $ln and INFORMATION/FIRST_NAME = $fn]"> <!--
              If there is a member with the same name as the player, then we consider that this
              player has become a member  -->
              <xsl:variable
                name="id"
                select="/TENNIS_CLUB/MEMBERS/MEMBER[INFORMATION/LAST_NAME = $ln and INFORMATION/FIRST_NAME = $fn]/@Id" />
                
                <tr>
                <td>
                  <xsl:value-of select="$ln" />
                </td>
                <td>
                  <xsl:value-of select="$fn" />
                </td>
                <td>
                  <xsl:value-of select="$id" />
                </td>
              </tr>


            </xsl:if>

          </xsl:for-each>
        </table>


      </body>
    </html>

  </xsl:template>

</xsl:stylesheet>