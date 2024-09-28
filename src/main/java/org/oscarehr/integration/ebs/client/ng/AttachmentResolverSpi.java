package org.oscarehr.integration.ebs.client.ng;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.Collection;

import org.apache.cxf.message.Attachment;
import org.apache.log4j.Logger;
import org.apache.xml.security.signature.XMLSignatureInput;
import org.apache.xml.security.utils.resolver.ResourceResolverContext;
import org.apache.xml.security.utils.resolver.ResourceResolverException;
import org.apache.xml.security.utils.resolver.ResourceResolverSpi;

/**
 * Resolver for accessing attachment parts within a message.
 * 
 * <h3>Implementation notes</h3>
 * 
 * Please note that this resolver is not thread safe and it depends on
 * {@link AttachmentCachingInterceptor} for initialization of 
 * attachments within current thread context.
 *
 */
public class AttachmentResolverSpi extends ResourceResolverSpi {
	
	private static final String SUPPORTED_URI_PREFIX = "cid:urn";

	private static final String ATTACHMENT_PREFIX = "cid:";

	private static Logger logger = Logger.getLogger(AttachmentResolverSpi.class);
	
	private Collection<Attachment> attachments;
	
    @Override
    public boolean engineIsThreadSafe() {
        return false;
    }

	@Override
	public boolean engineCanResolveURI(ResourceResolverContext context) {
		if (context.uriToResolve == null) {
			return false;
		}
		return context.uriToResolve.startsWith(SUPPORTED_URI_PREFIX);
	}

	@Override
	public XMLSignatureInput engineResolveURI(ResourceResolverContext context)
			throws ResourceResolverException {
		String resourceId = getResourceId(context);
		
		if (logger.isInfoEnabled()) {
			logger.info("Looking up: " + resourceId);
		}
		
		Attachment attachment = getAttachment(resourceId);
		
		if (attachment == null) {
			logger.error("Unable to resolve attachment for " + resourceId);
			
			throw new ResourceResolverException(context.uriToResolve, context.attr.getName(), context.baseUri);
		}
		
		if (logger.isInfoEnabled()) {
			logger.info("Found attachment: " + attachment);
		}
		
		XMLSignatureInput result;
		try {
			result = new XMLSignatureInput(attachment.getDataHandler().getInputStream());
		} catch (IOException e) {
			logger.error("Unable to create xml signature input", e);
			
			throw new ResourceResolverException(context.uriToResolve, context.attr.getName(), context.baseUri);
		}
		return result;
	}

	private String getResourceId(ResourceResolverContext context) {
		String resourceId = context.uriToResolve;
		try {
			resourceId = URLDecoder.decode(resourceId, "UTF-8");
		} catch (UnsupportedEncodingException e1) {
			throw new RuntimeException("Unable to decode", e1);
		}
		if (resourceId.startsWith(ATTACHMENT_PREFIX)) {
			resourceId = resourceId.substring(ATTACHMENT_PREFIX.length());
		}
		return resourceId;
	}
	
	private Attachment getAttachment(String resourceId) {
		Collection<Attachment> attachments = getAttachments();
		if (attachments == null) {
			return null;
		}
		
		for(Attachment a : attachments) {
			if (logger.isDebugEnabled()) {
				logger.debug("Comparing " + a.getId() + " with " + resourceId);
			}
			
			if (a.getId().equals(resourceId)) {
				return a;
			}
		}
		return null;
	}

	protected Collection<Attachment> getAttachments() {
		if (attachments == null) {
			attachments = AttachmentCachingInterceptor.getAttachments();
		}
		return attachments;
	}

}
