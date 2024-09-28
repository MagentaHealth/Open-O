package org.oscarehr.integration.ebs.client.ng;

import java.io.IOException;
import java.util.Map;
import java.util.Set;

import javax.xml.soap.SOAPMessage;

import org.apache.cxf.attachment.LazyAttachmentCollection;
import org.apache.cxf.binding.xml.interceptor.XMLMessageInInterceptor;
import org.apache.cxf.helpers.IOUtils;
import org.apache.cxf.interceptor.Fault;
import org.apache.cxf.message.Attachment;
import org.apache.cxf.message.Message;
import org.apache.cxf.phase.AbstractPhaseInterceptor;
import org.apache.cxf.phase.Phase;

public class DownloadInInterceptor extends AbstractPhaseInterceptor<Message> {

	public DownloadInInterceptor() {
		super(Phase.POST_INVOKE);
	}

	@Override
	public void handleMessage(Message message) throws Fault {
		LazyAttachmentCollection attachments = (LazyAttachmentCollection) 
				message.get(org.apache.cxf.message.Message.ATTACHMENTS);
		if (attachments != null) {
			for(Attachment a : attachments.getLoadedAttachments()) {
				System.out.println(a.getId());
				try {
					System.out.println(IOUtils.readStringFromStream(a.getDataHandler().getInputStream()));
				} catch (IOException e) {
					// swallow
				}
			}
		}
		
		
		for(Map.Entry<String, Object> entry : message.entrySet()) {
			System.out.println(entry.getKey() + " - " + entry.getValue());
		}
		
		// SOAPMessage soapMessage = (SOAPMessage) message;
	}

}
