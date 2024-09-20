package org.oscarehr.integration.ebs.client.ng;

import java.util.Collection;

import org.apache.cxf.interceptor.Fault;
import org.apache.cxf.message.Attachment;
import org.apache.cxf.message.Message;
import org.apache.cxf.phase.AbstractPhaseInterceptor;
import org.apache.cxf.phase.Phase;

/**
 * Caches attachments for the current message. Please remember to add {@link AttachmentCleanupInterceptor}
 * to the interceptor chain in order to remove cached attachements after processing.
 *
 * <h3>Implementation notes</h3>
 * 
 * This interceptor is invoked ta {@link Phase.PRE_PROTOCOL} phase and expects attachments
 * to be already parsed and configured on the {@link Message} instance before it is invoked.
 * It then sets the attachments in the thread local scope for further processing.
 */
public class AttachmentCachingInterceptor extends AbstractPhaseInterceptor<Message> {

	private static ThreadLocal<Collection<Attachment>> localInstance = new ThreadLocal<Collection<Attachment>>();

	public AttachmentCachingInterceptor() {
		super(Phase.PRE_PROTOCOL);
	}

	@Override
	public void handleMessage(Message message) throws Fault {
		localInstance.set(message.getAttachments());
	}

	public static Collection<Attachment> getAttachments() {
		Collection<Attachment> result = localInstance.get();
		return result;
	}

	public static void clear() {
		localInstance.remove();
	}

}
