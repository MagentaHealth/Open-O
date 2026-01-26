package ca.openosp.openo.integration.ebs.client.ng;

import org.apache.cxf.interceptor.Fault;
import org.apache.cxf.message.Message;
import org.apache.cxf.phase.AbstractPhaseInterceptor;
import org.apache.cxf.phase.Phase;
import org.apache.cxf.ws.security.wss4j.WSS4JInInterceptor;
import org.apache.logging.log4j.Logger;
import org.apache.wss4j.dom.handler.WSHandlerConstants;
import ca.openosp.openo.utility.MiscUtils;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.Map;

/**
 * Custom interceptor that dynamically configures WSS4J based on message content.
 * Detects encryption in the SOAP body and/or attachments, and configures actions accordingly.
 */
public class DynamicWSS4JInInterceptor extends AbstractPhaseInterceptor<Message> {

    private final EdtClientBuilder clientBuilder;
    private static final Logger logger = MiscUtils.getLogger();

    public DynamicWSS4JInInterceptor(EdtClientBuilder clientBuilder) {
        super(Phase.RECEIVE);
        this.clientBuilder = clientBuilder;
    }

    @Override
    public void handleMessage(Message message) {
        try {
            System.out.println("=== MCEDT DEBUG: DynamicWSS4JInInterceptor handling message ===");
            EncryptionDetectionResult detection = detectEncryption(message);

            System.out.println("Encryption detection: hasEncryption=" + detection.hasEncryption +
                             ", hasAttachmentEncryption=" + detection.hasAttachmentEncryption);

            Map<String, Object> wssProps = clientBuilder.newWSSInInterceptorConfiguration();

            String action;
            if (!detection.hasEncryption) {
                // No encryption → only timestamp and signature verification
                action = WSHandlerConstants.TIMESTAMP + " " + WSHandlerConstants.SIGNATURE;
                wssProps.put(WSHandlerConstants.ACTION, action);
                System.out.println("No encryption detected, using actions: " + action);
            } else if (detection.hasAttachmentEncryption) {
                // Both SOAP body and attachment encryption → encryption action twice
                action = WSHandlerConstants.TIMESTAMP + " " + WSHandlerConstants.SIGNATURE + " "
                                + WSHandlerConstants.ENCRYPTION + " " + WSHandlerConstants.ENCRYPTION;
                wssProps.put(WSHandlerConstants.ACTION, action);
                System.out.println("Both body and attachment encryption detected, using actions: " + action);
            } else {
                // Only one encryption block
                action = WSHandlerConstants.TIMESTAMP + " " + WSHandlerConstants.SIGNATURE + " " + WSHandlerConstants.ENCRYPTION;
                wssProps.put(WSHandlerConstants.ACTION, action);
                System.out.println("Body encryption detected, using actions: " + action);
            }

            // Add WSS4J interceptor to chain with appropriate configuration
            WSS4JInInterceptor wssInterceptor = new WSS4JInInterceptor(wssProps);
            message.getInterceptorChain().add(wssInterceptor);

            System.out.println("=== MCEDT DEBUG: WSS4J interceptor added to chain ===");

        } catch (Exception e) {
            System.out.println("=== MCEDT DEBUG: ERROR in DynamicWSS4JInInterceptor: " + e.getMessage() + " ===");
            logger.error("Error in DynamicWSS4JInInterceptor", e);
            throw new Fault(e);
        }
    }

    private static class EncryptionDetectionResult {
        boolean hasEncryption;
        boolean hasAttachmentEncryption;
    }

    /**
     * Detects if the incoming message has encryption in the SOAP body or encrypted attachments.
     */
    private EncryptionDetectionResult detectEncryption(Message message) {
        EncryptionDetectionResult result = new EncryptionDetectionResult();
        try {
            InputStream is = message.getContent(InputStream.class);
            if (is == null) {
                logger.warn("No InputStream found in message when detecting encryption.");
                return result;
            }

            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            byte[] buffer = new byte[1024];
            int len;
            while ((len = is.read(buffer)) != -1) {
                bos.write(buffer, 0, len);
            }

            String xml = bos.toString("UTF-8");

            // Reset stream so CXF can still process it downstream
            message.setContent(InputStream.class,
                    new java.io.ByteArrayInputStream(bos.toByteArray()));

            // Detect body encryption markers
            if (xml.contains("<wsse:EncryptedData") || xml.contains("<xenc:EncryptedData")) {
                result.hasEncryption = true;
            }

            // Detect attachment encryption markers
            if (xml.contains("Attachment-Content-Only")) {
                result.hasAttachmentEncryption = true;
            }

            // Extract and log KeyId information for debugging certificate mismatch issues
            if (result.hasEncryption) {
                extractAndLogKeyIdInfo(xml);
            }

            logger.debug("Encryption detection result: hasEncryption={}, hasAttachmentEncryption={}",
                    result.hasEncryption, result.hasAttachmentEncryption);

        } catch (Exception e) {
            logger.error("Error reading message content for encryption detection", e);
        }
        return result;
    }

    /**
     * Extracts and logs KeyId information from the encrypted SOAP message.
     * This helps diagnose certificate mismatch issues by showing what certificate
     * the MCEDT server used to encrypt the response.
     */
    private void extractAndLogKeyIdInfo(String xml) {
        try {
            System.out.println("=== MCEDT DEBUG: Analyzing KeyId in Encrypted Message ===");
            System.out.println("Looking for KeyInfo elements in EncryptedKey...");

            // First, check what encryption-related elements exist
            System.out.println("Checking for encryption structure elements:");
            System.out.println("  - Contains <xenc:EncryptedKey>: " + xml.contains("<xenc:EncryptedKey>"));
            System.out.println("  - Contains <EncryptedKey>: " + xml.contains("<EncryptedKey>"));
            System.out.println("  - Contains <ds:KeyInfo>: " + xml.contains("<ds:KeyInfo>"));
            System.out.println("  - Contains <KeyInfo>: " + xml.contains("<KeyInfo>"));
            System.out.println("  - Contains <wsse:SecurityTokenReference>: " + xml.contains("<wsse:SecurityTokenReference>"));
            System.out.println("  - Contains <SecurityTokenReference>: " + xml.contains("<SecurityTokenReference>"));
            System.out.println("  - Contains <ds:X509Data>: " + xml.contains("<ds:X509Data>"));
            System.out.println("  - Contains <X509Data>: " + xml.contains("<X509Data>"));
            System.out.println("");

            boolean foundKeyInfo = false;

            // Check for X509IssuerSerial (most common - this is what MCEDT typically uses)
            if (xml.contains("<ds:X509IssuerSerial>") || xml.contains("<X509IssuerSerial>") ||
                xml.contains(":X509IssuerSerial>")) {
                foundKeyInfo = true;
                String issuerName = extractXmlElement(xml, "X509IssuerName");
                String serialNumber = extractXmlElement(xml, "X509SerialNumber");

                System.out.println(">>> KeyId Type: X509IssuerSerial (Certificate Identity) <<<");
                System.out.println("  Issuer Name: " + (issuerName != null ? issuerName : "NOT FOUND"));
                System.out.println("  Serial Number: " + (serialNumber != null ? serialNumber : "NOT FOUND"));
                System.out.println("");
                System.out.println("  This means MCEDT encrypted the message for a certificate with:");
                System.out.println("  - Issuer: " + issuerName);
                System.out.println("  - Serial: " + serialNumber);
                System.out.println("");
            }

            // Check for Subject Key Identifier (also common)
            if (xml.contains("<ds:X509SKI>") || xml.contains("<X509SKI>") || xml.contains(":X509SKI>")) {
                foundKeyInfo = true;
                String ski = extractXmlElement(xml, "X509SKI");
                System.out.println(">>> KeyId Type: X509SKI (Subject Key Identifier) <<<");
                System.out.println("  SKI Value: " + (ski != null ? ski : "NOT FOUND"));
                System.out.println("");
            }

            // Check for X509SubjectName
            if (xml.contains("<ds:X509SubjectName>") || xml.contains("<X509SubjectName>") ||
                xml.contains(":X509SubjectName>")) {
                foundKeyInfo = true;
                String subjectName = extractXmlElement(xml, "X509SubjectName");
                System.out.println(">>> KeyId Type: X509SubjectName <<<");
                System.out.println("  Subject: " + (subjectName != null ? subjectName : "NOT FOUND"));
                System.out.println("");
            }

            // Check for direct certificate reference
            if (xml.contains("<ds:X509Certificate>") || xml.contains("<X509Certificate>") ||
                xml.contains(":X509Certificate>")) {
                foundKeyInfo = true;
                String certSnippet = extractXmlElement(xml, "X509Certificate");
                if (certSnippet != null && certSnippet.length() > 80) {
                    certSnippet = certSnippet.substring(0, 80) + "... (truncated)";
                }
                System.out.println(">>> KeyId Type: X509Certificate (Direct Certificate Embedding) <<<");
                System.out.println("  Certificate Data (first 80 chars): " + certSnippet);
                System.out.println("");
            }

            // Check for KeyName
            if (xml.contains("<ds:KeyName>") || xml.contains("<KeyName>") || xml.contains(":KeyName>")) {
                foundKeyInfo = true;
                String keyName = extractXmlElement(xml, "KeyName");
                System.out.println(">>> KeyId Type: KeyName <<<");
                System.out.println("  KeyName: " + (keyName != null ? keyName : "NOT FOUND"));
                System.out.println("");
            }

            if (!foundKeyInfo) {
                System.out.println("WARNING: No standard KeyInfo elements found in the encrypted message!");
                System.out.println("This is unusual for WS-Security encrypted messages.");
                System.out.println("");
                System.out.println("Attempting to extract EncryptedKey section for manual inspection...");

                // Try to extract and show the EncryptedKey section
                String encryptedKeySection = extractEncryptedKeySection(xml);
                if (encryptedKeySection != null) {
                    System.out.println("--- EncryptedKey Section (first 1000 chars) ---");
                    if (encryptedKeySection.length() > 1000) {
                        System.out.println(encryptedKeySection.substring(0, 1000) + "...(truncated)");
                    } else {
                        System.out.println(encryptedKeySection);
                    }
                    System.out.println("--- End EncryptedKey Section ---");
                } else {
                    System.out.println("Could not extract EncryptedKey section.");
                    System.out.println("Showing first 2000 chars of entire message:");
                    System.out.println("--- Message Start ---");
                    if (xml.length() > 2000) {
                        System.out.println(xml.substring(0, 2000) + "...(truncated)");
                    } else {
                        System.out.println(xml);
                    }
                    System.out.println("--- Message End ---");
                }
            }

            System.out.println("=== MCEDT DEBUG: End KeyId Analysis ===");
            System.out.println("");

        } catch (Exception e) {
            System.out.println("ERROR extracting KeyId info: " + e.getMessage());
            logger.error("Error extracting KeyId information", e);
        }
    }

    /**
     * Extracts the EncryptedKey section from the SOAP message.
     */
    private String extractEncryptedKeySection(String xml) {
        try {
            // Try different variations of EncryptedKey tag
            String[] startTags = {
                "<xenc:EncryptedKey",
                "<EncryptedKey",
                ":EncryptedKey"
            };

            String[] endTags = {
                "</xenc:EncryptedKey>",
                "</EncryptedKey>",
                ":EncryptedKey>"
            };

            for (String startTag : startTags) {
                int startIdx = xml.indexOf(startTag);
                if (startIdx != -1) {
                    // Find matching end tag
                    for (String endTag : endTags) {
                        int endIdx = xml.indexOf(endTag, startIdx);
                        if (endIdx != -1) {
                            endIdx += endTag.length();
                            return xml.substring(startIdx, endIdx);
                        }
                    }
                }
            }
            return null;
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Simple helper to extract content from an XML element.
     * Handles elements with or without namespace prefixes.
     */
    private String extractXmlElement(String xml, String elementName) {
        try {
            // Try with ds: prefix first
            String withPrefix = extractElementContent(xml, "ds:" + elementName);
            if (withPrefix != null) {
                return withPrefix;
            }

            // Try without prefix
            return extractElementContent(xml, elementName);
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Extracts content between opening and closing tags.
     */
    private String extractElementContent(String xml, String tagName) {
        String startTag = "<" + tagName + ">";
        String endTag = "</" + tagName + ">";

        int startIdx = xml.indexOf(startTag);
        if (startIdx == -1) {
            // Try with attributes
            startTag = "<" + tagName + " ";
            startIdx = xml.indexOf(startTag);
            if (startIdx != -1) {
                // Find the end of the opening tag
                int tagEndIdx = xml.indexOf(">", startIdx);
                if (tagEndIdx != -1) {
                    startIdx = tagEndIdx + 1;
                } else {
                    return null;
                }
            } else {
                return null;
            }
        } else {
            startIdx += startTag.length();
        }

        int endIdx = xml.indexOf(endTag, startIdx);
        if (endIdx == -1) {
            return null;
        }

        String content = xml.substring(startIdx, endIdx).trim();
        return content.isEmpty() ? null : content;
    }
}
