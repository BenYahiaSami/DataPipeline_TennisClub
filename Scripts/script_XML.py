from lxml import etree

# File names
xml_file = "tennis_club_rg.xml"
xsd_file = "schema1.xsd"
xsl_file = "Visualization/Visualization_Sceneario_1.xsl"
output_file = "script_XML_Result.xml"

# 1. Load XML
try:
    xml_doc = etree.parse(xml_file)
    print("XML loaded successfully.")
except Exception as e:
    print("Error while loading XML:", e)
    exit()

# 2. Validate XML with XSD
try:
    xsd_doc = etree.parse(xsd_file)
    schema = etree.XMLSchema(xsd_doc)

    if schema.validate(xml_doc):
        print("XML is valid against XSD.")
    else:
        print("XML is NOT valid against XSD.")
        for error in schema.error_log:
            print(error.message)
        exit()
except Exception as e:
    print("Error while validating XML:", e)
    exit()

# 3. Apply XSLT
try:
    xsl_doc = etree.parse(xsl_file)
    transform = etree.XSLT(xsl_doc)
    result = transform(xml_doc)

    with open(output_file, "wb") as f:
        f.write(etree.tostring(result, pretty_print=True, encoding="UTF-8", xml_declaration=True))

    print("Transformation completed successfully.")
    print("Result saved in:", output_file)
except Exception as e:
    print("Error while applying XSLT:", e)
    exit()