package org.oscarehr.integration.ebs.client.ng;

import java.util.UUID;

public class EdtClientBuilderConfig {

	private String userNameTokenUser;

	private String userNameTokenPassword;

	private String keystoreUser;

	private String keystorePassword;

	private String serviceUrl;

	private String conformanceKey;

	private String auditId;

	private String serviceId;

	private boolean loggingRequired;

	private boolean mtomEnabled;
	
	public EdtClientBuilderConfig() {
		setAuditId(UUID.randomUUID().toString());
	}
	
	public String getUserNameTokenUser() {
		return userNameTokenUser;
	}

	public void setUserNameTokenUser(String username) {
		this.userNameTokenUser = username;
	}

	public String getUserNameTokenPassword() {
		return userNameTokenPassword;
	}

	public void setUserNameTokenPassword(String password) {
		this.userNameTokenPassword = password;
	}

	public String getServiceUrl() {
		return serviceUrl;
	}

	public void setServiceUrl(String serviceUrl) {
		this.serviceUrl = serviceUrl;
	}

	public String getConformanceKey() {
		return conformanceKey;
	}

	public void setConformanceKey(String conformanceKey) {
		this.conformanceKey = conformanceKey;
	}

	public String getAuditId() {
		return auditId;
	}

	public void setAuditId(String auditId) {
		this.auditId = auditId;
	}

	public String getKeystoreUser() {
		return keystoreUser;
	}

	public void setKeystoreUser(String keystoreUsername) {
		this.keystoreUser = keystoreUsername;
	}

	public String getKeystorePassword() {
		return keystorePassword;
	}

	public void setKeystorePassword(String keystorePassword) {
		this.keystorePassword = keystorePassword;
	}

	public String getServiceId() {
		return serviceId;
	}

	public void setServiceId(String serviceId) {
		this.serviceId = serviceId;
	}

	public boolean isLoggingRequired() {
		return loggingRequired;
	}

	public void setLoggingRequired(boolean loggingRequired) {
		this.loggingRequired = loggingRequired;
	}

	public boolean isMtomEnabled() {
		return mtomEnabled;
	}

	public void setMtomEnabled(boolean mtomEnabled) {
		this.mtomEnabled = mtomEnabled;
	}
}
