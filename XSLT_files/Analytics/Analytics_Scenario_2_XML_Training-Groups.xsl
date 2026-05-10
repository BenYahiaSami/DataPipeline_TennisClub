<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT stylesheet that transforms training group data into an analytics report -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- Output the result as pretty-printed XML -->
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <!-- Start processing from the root of the XML document -->
    <xsl:template match="/">
        <TrainingGroupsAnalytics>
            <!-- Loop through every training group -->
            <xsl:for-each select="/TENNIS_CLUB/TRAINING_GROUPS/TRAINING_GROUP">

                <!-- Store the current group ID in a variable -->
                <xsl:variable name="groupId" select="@Id"/>

                <!-- Count how many members belong to this group -->
                <xsl:variable name="membersCount" select="count(MEMBERSID)"/>

                <!-- Count how many training sessions are linked to this group -->
                <xsl:variable name="sessionsCount" select="count(/TENNIS_CLUB/TRAINING_SESSIONS/TRAINING_SESSION[TRAININGGROUPID = $groupId])"/>

                <Group>
                    <!-- Group identifier -->
                    <GroupID>
                        <xsl:value-of select="$groupId"/>
                    </GroupID>

                    <!-- Group level -->
                    <Level>
                        <xsl:value-of select="LEVEL"/>
                    </Level>

                    <!-- Number of members in the group -->
                    <MembersCount>
                        <xsl:value-of select="$membersCount"/>
                    </MembersCount>

                    <!-- Number of sessions linked to the group -->
                    <SessionsCount>
                        <xsl:value-of select="$sessionsCount"/>
                    </SessionsCount>

                    <!-- Activity category based on the number of sessions -->
                    <ActivityCategory>
                        <xsl:choose>
                            <xsl:when test="$sessionsCount = 0">Low</xsl:when>
                            <xsl:when test="$sessionsCount = 1">Medium</xsl:when>
                            <xsl:otherwise>High</xsl:otherwise>
                        </xsl:choose>
                    </ActivityCategory>
                </Group>
            </xsl:for-each>
        </TrainingGroupsAnalytics>
    </xsl:template>

</xsl:stylesheet>