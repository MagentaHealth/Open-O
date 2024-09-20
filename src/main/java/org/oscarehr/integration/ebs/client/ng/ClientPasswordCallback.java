package org.oscarehr.integration.ebs.client.ng;

import java.io.IOException;

import javax.security.auth.callback.Callback;
import javax.security.auth.callback.CallbackHandler;
import javax.security.auth.callback.UnsupportedCallbackException;

import org.apache.wss4j.common.ext.WSPasswordCallback;

public class ClientPasswordCallback implements CallbackHandler {

	private String username;
	private String password;

	private String keystoreAlias;
	private String keystorePassword;

	public ClientPasswordCallback(String username, String password,
			String keystoreAlias, String keystorePassword) {
		this.username = username;
		this.password = password;
		this.keystoreAlias = keystoreAlias;
		this.keystorePassword = keystorePassword;
	}

	public void handle(Callback[] callbacks) throws IOException,
			UnsupportedCallbackException {
		for (Callback c : callbacks) {
			if (c instanceof WSPasswordCallback) {
				WSPasswordCallback pc = (WSPasswordCallback) c;
				switch (pc.getUsage()) {
				case WSPasswordCallback.USERNAME_TOKEN:
					// for some reason, CXF uses the same username for both
					// the keystore and the username token - we need to override
					// it to make it work
					pc.setIdentifier(username);
					pc.setPassword(password);
					break;
				case WSPasswordCallback.DECRYPT:
				case WSPasswordCallback.SIGNATURE:
					pc.setIdentifier(keystoreAlias);
					pc.setPassword(keystorePassword);
					break;
				default:
					throw new UnsupportedCallbackException(c,
							"Unsupported callback type");
				}
			}
		}
	}
}
