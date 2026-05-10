import java.io.File;
import java.io.IOException;
import javax.swing.JFileChooser;
import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

public class script_JAVA {

    public static void main(String[] args) {
        // Input XML file
        String xmlFile = "tennis_club_rg.xml";
        
        // XSD schema file used to validate the XML
        
        String xsdFile = "schema1.xsd";

        try {
            // Open a file chooser so the user can select the XSL file manually
            JFileChooser chooser = new JFileChooser();
            chooser.setDialogTitle("Select XSL file");

            // Show the file selection window
            int choice = chooser.showOpenDialog(null);

            // If the user cancels, stop the program
            if (choice != JFileChooser.APPROVE_OPTION) {
                System.out.println("No XSL file selected.");
                return;
            }

            // Get the selected XSL file path
            File xslChosenFile = chooser.getSelectedFile();
            String xslFile = xslChosenFile.getAbsolutePath();

            // Create a DOM parser for the XML document
            DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
            dbFactory.setNamespaceAware(true);

            // Parse the XML file into a DOM Document
            DocumentBuilder builder = dbFactory.newDocumentBuilder();
            Document xmlDoc = builder.parse(new File(xmlFile));
            System.out.println("XML loaded successfully.");

            // Load the XSD schema
            SchemaFactory schemaFactory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
            Schema schema = schemaFactory.newSchema(new File(xsdFile));

            // Validate the XML document against the XSD
            Validator validator = schema.newValidator();
            validator.validate(new DOMSource(xmlDoc));
            System.out.println("XML is valid against XSD.");

            // Load the XSL stylesheet
            TransformerFactory transformerFactory = TransformerFactory.newInstance();
            Source xslSource = new StreamSource(new File(xslFile));
            Transformer transformer = transformerFactory.newTransformer(xslSource);

            // Decide the appropriate output type
            String method = transformer.getOutputProperty(OutputKeys.METHOD);
            String extension;

            if (method == null || method.equalsIgnoreCase("xml")) {
                extension = "xml";
            } else if (method.equalsIgnoreCase("html")) {
                extension = "html";
            } else if (method.equalsIgnoreCase("text")) {
                extension = "txt";
            } else {
                extension = "out";
            }

            String outputFile = "script_java_Result." + extension;

            // Apply the XSL transformation and save the result
            Result result = new StreamResult(new File(outputFile));
            transformer.transform(new DOMSource(xmlDoc), result);

            System.out.println("Transformation completed successfully.");
            System.out.println("Output method detected: " + method);
            System.out.println("Result saved in: " + outputFile);

        } catch (ParserConfigurationException | IOException | SAXException | TransformerException e) {
            System.out.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}