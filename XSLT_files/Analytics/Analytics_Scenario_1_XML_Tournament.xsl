<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT stylesheet that reads tournament data from TENNIS_CLUB XML -->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Output XML with indentation -->
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>

	<!-- Start processing from the document root -->
	<xsl:template match="/">
		<TournamentAnalytics>
			<!-- Loop through every TOURNAMENT inside TENNIS_CLUB -->
			<xsl:for-each select="/TENNIS_CLUB/TOURNAMENTS/TOURNAMENT">
				<TournamentSummary>
					<!-- Read the tournament attribute Id -->
					<TournamentID>
						<xsl:value-of select="@Id"/>
					</TournamentID>

					<!-- Read the tournament name -->
					<TournamentName>
						<xsl:value-of select="NAME"/>
					</TournamentName>

					<!-- Read the tournament level -->
					<Level>
						<xsl:value-of select="LEVEL"/>
					</Level>

					<!-- Count how many member references are in this tournament -->
					<ParticipantsCount>
						<xsl:value-of select="count(MEMBERSID)"/>
					</ParticipantsCount>

					<!-- Read the tournament price -->
					<Prize>
						<xsl:value-of select="PRICE"/>
					</Prize>

					<!-- Check whether at least one winner exists -->
					<HasWinner>
						<xsl:choose>
							<xsl:when test="WINNER">Yes</xsl:when>
							<xsl:otherwise>No</xsl:otherwise>
						</xsl:choose>
					</HasWinner>

					<!-- Output all winners, if there are several -->
					<Winners>
						<xsl:for-each select="WINNER">
							<Winner>
								<xsl:value-of select="."/>
							</Winner>
						</xsl:for-each>
					</Winners>
				</TournamentSummary>
			</xsl:for-each>
		</TournamentAnalytics>
	</xsl:template>

</xsl:stylesheet>