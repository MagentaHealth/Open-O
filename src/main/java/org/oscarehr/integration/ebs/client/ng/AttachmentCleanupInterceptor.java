package org.oscarehr.integration.ebs.client.ng;

import org.apache.cxf.interceptor.Fault;
import org.apache.cxf.message.Message;
import org.apache.cxf.phase.AbstractPhaseInterceptor;
import org.apache.cxf.phase.Phase;

/**
 * Cleans up attachments cached by {@link AttachmentCachingInterceptor}.
 */
public class AttachmentCleanupInterceptor extends
		AbstractPhaseInterceptor<Message> {

	public AttachmentCleanupInterceptor() {
		super(Phase.POST_INVOKE);
	}

	@Override
	public void handleMessage(Message message) throws Fault {
		AttachmentCachingInterceptor.clear();
	}
}
