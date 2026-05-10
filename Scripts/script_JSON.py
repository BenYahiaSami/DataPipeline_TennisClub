from lxml import etree
import json

# Input XML file
xml_file = "tennis_club_rg.xml"

# Output JSON file
output_file = "script_JSON_Result.json"

# Parse the XML file into a tree
xml_doc = etree.parse(xml_file)

# Create an empty list to store the report for each member
report = []

# Loop through every MEMBER node in the club
for member in xml_doc.xpath("/TENNIS_CLUB/MEMBERS/MEMBER"):
    # Read the member ID attribute
    member_id = member.get("Id")

    # Read the first name from the INFORMATION section
    first_name = member.xpath("string(INFORMATION/FIRST_NAME)")

    # Read the last name from the INFORMATION section
    last_name = member.xpath("string(INFORMATION/LAST_NAME)")

    # Get all memberships of the current member
    memberships = member.xpath("MEMBERSHIPS/MEMBERSHIP")

    # Count how many memberships the member has
    memberships_count = len(memberships)

    # Default values if the member has no memberships
    last_membership_level = ""
    status = "expired"

    # If the member has at least one membership, use the last one
    if memberships:
        last_membership = memberships[-1]

        # Read the level of the last membership
        last_membership_level = last_membership.xpath("string(MEMBERLEVEL)")

        # Read the end date of the last membership
        end_date = last_membership.xpath("string(END_DATE)")

        # Mark the member as active if the last membership ends after 2025
        if end_date[:4].isdigit() and int(end_date[:4]) > 2025:
            status = "active"

    # Add the member information to the report list
    report.append({
        "memberId": member_id,
        "fullName": f"{first_name} {last_name}".strip(),
        "membershipsCount": memberships_count,
        "lastMembershipLevel": last_membership_level,
        "status": status
    })

# Build the final JSON structure
result = {"membersMembershipReport": report}

# Save the JSON result to a file
with open(output_file, "w", encoding="utf-8") as f:
    json.dump(result, f, ensure_ascii=False, indent=2)

# Confirm that the report was saved
print("Report saved in:", output_file)