/**
 * Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
 * This software is published under the GPL GNU General Public License.
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * This software was written for the
 * Department of Family Medicine
 * McMaster University
 * Hamilton
 * Ontario, Canada
 */


package oscar.login;

import java.util.Date;
import java.util.List;

import org.apache.logging.log4j.Logger;
import org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.PMmodule.dao.SecUserRoleDao;
import org.oscarehr.PMmodule.model.SecUserRole;
import org.oscarehr.common.dao.SecurityDao;
import org.oscarehr.common.model.Provider;
import org.oscarehr.common.model.Security;
import org.oscarehr.managers.MfaManager;
import org.oscarehr.managers.SecurityManager;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SSOUtility;
import org.oscarehr.util.SpringUtils;
import com.quatro.model.security.LdapSecurity;
import org.owasp.encoder.Encode;
import oscar.OscarProperties;
import oscar.log.LogAction;
import oscar.log.LogConst;

public final class LoginCheckLoginBean {
	private static final Logger logger = MiscUtils.getLogger();
	private static final String LOG_PRE = "Login!@#$: ";

	private final SecurityManager securityManager = SpringUtils.getBean(SecurityManager.class);

	private String username = "";
	private String password = "";
	private String pin;
	private String ip = "";
	private String ssoKey = "";

	private String userpassword; // your password in the table

	private String firstname;
	private String lastname;
	private String profession;
	private String rolename;

	private String email;

	private Security security = null;

	public void ini(String user_name, String password, String pin1, String ip1) {
		setUsername(user_name);
		setPassword(password);
		setPin(pin1);
		setIp(ip1);
	}
	
	public void ssoIni(String ssoKey) {
		setSsoKey(ssoKey);
	}

	public String[] authenticate() {
		security = getUserID();

		// the user is not in security table
		if (security == null) {
			return cleanNullObj(LOG_PRE + "No Such User: " + username);
		}
		// check pin if needed

		String sPin = pin;

		if (sPin != null && oscar.OscarProperties.getInstance().isPINEncripted()) sPin = oscar.Misc.encryptPIN(sPin);

		/*
		 * Override PIN requirement when SSO is enabled
		 * The pin parameter is set to null in the LoginCheckLogin bean and
		 * is changed back to default empty after the pin requirement is disabled.
		 */
		if(sPin == null && SSOUtility.isSSOEnabled()) {
			security.setBRemotelockset(0);
			security.setBLocallockset(0);
			sPin = "";
		}

		if (this.isPinCheckEnabled() && isWAN() && security.getBRemotelockset() != null && security.getBRemotelockset().intValue() == 1 && (!sPin.equals(security.getPin()) || pin.length() < 3)) {
			return cleanNullObj(LOG_PRE + "Pin-remote needed: " + username);
		} else if (this.isPinCheckEnabled() && !isWAN() && security.getBLocallockset() != null && security.getBLocallockset().intValue() == 1 && (!sPin.equals(security.getPin()) || pin.length() < 3)) {
			return cleanNullObj(LOG_PRE + "Pin-local needed: " + username);
		}

		if (security.getBExpireset() != null && security.getBExpireset().intValue() == 1 && (security.getDateExpiredate() == null || security.getDateExpiredate().before(new Date()))) {
			return cleanNullObjExpire(LOG_PRE + "Expired: " + username);
		}

		String expired_days = "";
		if (security.getBExpireset() != null && security.getBExpireset().intValue() == 1) {
			// Give warning if the password will be expired in 10 days.

			long date_expireDate = security.getDateExpiredate().getTime();
			long date_now = new Date().getTime();
			long date_diff = (date_expireDate - date_now) / (24 * 3600 * 1000);

			if (security.getBExpireset().intValue() == 1 && date_diff < 11) {
				expired_days = String.valueOf(date_diff);
			}
		}

		boolean auth = false;

		userpassword = security.getPassword();
		if (userpassword.length() < 20) {
			auth = password.equals(userpassword);
			if (auth) {
				boolean isPasswordUpgraded = this.securityManager.upgradeSavePasswordHash(this.password, this.security);
				if (!isPasswordUpgraded)
					logger.error("Error while upgrading password hash");
			}
		} else {
			auth = this.securityManager.validatePassword(this.password, this.security);
		}

		if (auth) { // login successfully
			String[] strAuth = new String[7];
			strAuth[0] = security.getProviderNo();
			strAuth[1] = firstname;
			strAuth[2] = lastname;
			strAuth[3] = profession;
			strAuth[4] = rolename;
			strAuth[5] = expired_days;
			strAuth[6] = email;
			return strAuth;
		} else { // login failed
			return cleanNullObj(LOG_PRE + "password failed: " + username);
		}
	}
	
	public String[] ssoAuthenticate() {
		security = getUserIDWithSSOKey();
		String [] strAuth;
		if (security != null) {
			String expired_days = "";
			strAuth = new String[7];
			strAuth[0] = security.getProviderNo();
			strAuth[1] = firstname;
			strAuth[2] = lastname;
			strAuth[3] = profession;
			strAuth[4] = rolename;
			strAuth[5] = expired_days;
			strAuth[6] = email;
			
		}
		else {
			strAuth = cleanNullObj(LOG_PRE + "ssoKey does not match a record");
		}
		
		return strAuth;
	}

	private String[] cleanNullObj(String errorMsg) {
		logger.warn(errorMsg);
		LogAction.addLogSynchronous("", "failed", LogConst.CON_LOGIN, Encode.forHtmlContent(username), ip);
		userpassword = null;
		password = null;
		return null;
	}

	private String[] cleanNullObjExpire(String errorMsg) {
		logger.warn(errorMsg);
		LogAction.addLogSynchronous("", "expired", LogConst.CON_LOGIN, Encode.forHtmlContent(username), ip);
		userpassword = null;
		password = null;
		return new String[] { "expired" };
	}

	private Security getUserID() {

		SecurityDao securityDao = (SecurityDao) SpringUtils.getBean(SecurityDao.class);
		List<Security> results = securityDao.findByUserName(username);
		Security security = null;
		if (results.size() > 0) security = results.get(0);

		if (security == null) {
			return null;
		} else if (OscarProperties.isLdapAuthenticationEnabled()) {
			security = new LdapSecurity(security);
		}

		// find the detail of the user
		ProviderDao providerDao = (ProviderDao) SpringUtils.getBean(ProviderDao.class);
		Provider provider = providerDao.getProvider(security.getProviderNo());

		if (provider != null) {
			firstname = provider.getFirstName();
			lastname = provider.getLastName();
			profession = provider.getProviderType();
			email = provider.getEmail();
		}

		// retrieve the oscar roles for this Provider as a comma separated list
		SecUserRoleDao secUserRoleDao = (SecUserRoleDao) SpringUtils.getBean(SecUserRoleDao.class);
		List<SecUserRole> roles = secUserRoleDao.getUserRoles(security.getProviderNo());
		for (SecUserRole role : roles) {
			if (rolename == null) {
				rolename = role.getRoleName();
			} else {
				rolename += "," + role.getRoleName();
			}
		}

		return security;
	}
	
	private Security getUserIDWithSSOKey() {
		SecurityDao securityDao = (SecurityDao) SpringUtils.getBean(SecurityDao.class);
		List<Security> securityResults = securityDao.findByOneIdKey(ssoKey); 
		Security securityRecord = null;
		
		if (securityResults != null && securityResults.size() > 0) {
			securityRecord = securityResults.get(0);
		}
		
		if (securityRecord != null) {
			if (OscarProperties.isLdapAuthenticationEnabled()) {
				securityRecord = new LdapSecurity(securityRecord);
			}
			
			// Gets the provider record
			ProviderDao providerDao = (ProviderDao) SpringUtils.getBean(ProviderDao.class);
			Provider provider = providerDao.getProvider(securityRecord.getProviderNo());

			if (provider == null || (provider.getStatus() != null && provider.getStatus().equals("0"))) {
				String error = "Provider account is missing or inactive. Provider number: " + securityRecord.getProviderNo();
				logger.error(error);
				LogAction.addLog(securityRecord.getProviderNo(), "login", "failed", "inactive");
				return null;
			} else {
				firstname = provider.getFirstName();
				lastname = provider.getLastName();
			}

			// retrieve the oscar roles for this Provider as a comma separated list
			SecUserRoleDao secUserRoleDao = (SecUserRoleDao) SpringUtils.getBean(SecUserRoleDao.class);
			List<SecUserRole> roles = secUserRoleDao.getUserRoles(securityRecord.getProviderNo());
			for (SecUserRole role : roles) {
				if (rolename == null) {
					rolename = role.getRoleName();
				} else {
					rolename += "," + role.getRoleName();
				}
			}
		}
		
		return securityRecord;
	}

	public boolean isWAN() {
		boolean bWAN = true;
		//Properties p = OscarProperties.getInstance();
		//if (ip.startsWith(p.getProperty("login_local_ip"))) bWAN = false;
		if(LoginCheckLogin.ipFound(ip)) bWAN = false;
		return bWAN;
	}

	public void setUsername(String user_name) {
		this.username = user_name;
	}

	public void setPassword(String password) {
		this.password = password.replace(' ', '\b'); // no white space to be allowed in the password
	}

	public void setPin(String pin1) {
		if(pin1 != null) {
			this.pin = pin1.replace(' ', '\b');
		}
	}

	public void setIp(String ip1) {
		this.ip = ip1;
	}
	
	public void setSsoKey(String ssoKey) {
		this.ssoKey = ssoKey;
	}

	public Security getSecurity() {
		return (security);
	}

	/**
	 * Checks if PIN check is enabled globally and for the current user.
	 *
	 * @return true if PIN check is enabled and the user is not using MFA, false otherwise.
	 */
	private boolean isPinCheckEnabled() {
		return MfaManager.isOscarLegacyPinEnabled() && !security.isUsingMfa();
	}

}
