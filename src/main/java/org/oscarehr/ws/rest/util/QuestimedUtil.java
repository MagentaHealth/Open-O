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
package org.oscarehr.ws.rest.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.security.Key;
import java.security.NoSuchAlgorithmException;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import org.apache.logging.log4j.Logger;

import java.util.Base64;

import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.dao.UserPropertyDAO;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.common.model.UserProperty;
import org.oscarehr.integration.questimed.QuestimedSSO;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import oscar.OscarProperties;
import oscar.log.LogAction;
import oscar.log.LogConst;

public class QuestimedUtil {

    private static Logger logger = MiscUtils.getLogger();
    private static UserPropertyDAO userPropertyDao = SpringUtils.getBean(UserPropertyDAO.class);
    private static DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
    private static SecretKey secretKey = null;

    public static boolean isServiceConnectionReady() {
        String cr = getServiceUserName();
        if (cr == null || cr.trim().isEmpty()) {
            return false;
        }

        cr = getServicePassword();
        if (cr == null || cr.trim().isEmpty()) {
            return false;
        }

        cr = getServiceLocation();
        if (cr == null || cr.trim().isEmpty()) {
            return false;
        }

        return true;
    }

    public static String getSurveysBody(LoggedInInfo loggedInInfo, String demographicNo) {
        String providerNo = loggedInInfo.getLoggedInProviderNo();

        if (demographicNo != null) {
            LogAction.addLog(loggedInInfo, "Sent to Questimed", "Patient demoNo", demographicNo, demographicNo, null);
        }
        return QuestimedSSO.getSurveysBody(getServiceUserName(), getServicePassword(), getServiceLocation(), getUsername(providerNo), demographicNo, providerNo);
    }

    public static String getLaunchURL(LoggedInInfo loggedInInfo, String demographicNo) {
        String providerNo = loggedInInfo.getLoggedInProviderNo();

        if (demographicNo != null) {
            LogAction.addLog(loggedInInfo, "Sent to Questimed", "Patient demoNo", demographicNo, demographicNo, null);
        }
        String mainUrl = QuestimedSSO.getLaunchURL(getServiceUserName(), getServicePassword(), getServiceLocation(), getUsername(providerNo), demographicNo, providerNo);

        return mainUrl;
    }

    public static String createAccount(LoggedInInfo loggedInInfo, String demographicNo, String patientEmail) {
        String providerNo = loggedInInfo.getLoggedInProviderNo();
        String patientHCN = null;
        String patientFirstName = null;
        String patientLastName = null;
        String patientDOB = null;
        String patientSex = null;

        if (demographicNo != null) {
            Demographic demo = demographicDao.getDemographic(demographicNo);
            patientHCN = demo.getHin();
            patientFirstName = demo.getFirstName();
            patientLastName = demo.getLastName();
            patientDOB = demo.getBirthDayAsString();
            patientSex = demo.getSex();
            LogAction.addLog(loggedInInfo, "Create Questimed Account", LogConst.CON_DEMOGRAPHIC, demographicNo, demographicNo, null);
        }

        String errorMsg = QuestimedSSO.createAccount(getServiceUserName(), getServicePassword(), getServiceLocation(), getUsername(providerNo), patientHCN, demographicNo, providerNo, patientFirstName, patientLastName, patientDOB, patientSex, patientEmail);

        return errorMsg;
    }

    public static Boolean testServiceConnection() {
        if (isServiceConnectionReady() == false) {
            return null;
        }
        return QuestimedSSO.testServiceConnection(getServiceUserName(), getServicePassword(), getServiceLocation());
    }

    public static String getServiceUserName() {
        UserProperty prop = userPropertyDao.getProp(UserProperty.QUESTIMED_SERVICE_USERNAME);
        if (prop != null) {
            return decryptAes(getAesEncryptionKey(), prop.getValue());
        } else {
            return null;
        }
    }

    public static String getServicePassword() {
        UserProperty prop = userPropertyDao.getProp(UserProperty.QUESTIMED_SERVICE_PASSWORD);
        if (prop != null) {
            return decryptAes(getAesEncryptionKey(), prop.getValue());
        } else {
            return null;
        }
    }

    public static String getServiceLocation() {
        UserProperty prop = userPropertyDao.getProp(UserProperty.QUESTIMED_SERVICE_LOCATION);
        if (prop != null) {
            return prop.getValue();
        } else {
            return null;
        }
    }

    public static void saveServiceUsername(String serviceUserName) {
        userPropertyDao.saveProp(UserProperty.QUESTIMED_SERVICE_USERNAME, encryptAes(getAesEncryptionKey(), serviceUserName));
    }

    public static void saveServicePassword(String servicePassword) {
        userPropertyDao.saveProp(UserProperty.QUESTIMED_SERVICE_PASSWORD, encryptAes(getAesEncryptionKey(), servicePassword));
    }

    public static void saveServiceLocation(String serviceLocation) {
        userPropertyDao.saveProp(UserProperty.QUESTIMED_SERVICE_LOCATION, serviceLocation);
    }

//--- private methods ---//
    private static String getUsername(String providerNo) {
        UserProperty prop = userPropertyDao.getProp(providerNo, UserProperty.QUESTIMED_USERNAME);
        if (prop != null) {
            return prop.getValue();
        } else {
            return null;
        }
    }

    private static SecretKey getAesEncryptionKey() {
        if (secretKey != null) {
            return secretKey;
        }

        String documentDir = OscarProperties.getInstance().getProperty("DOCUMENT_DIR");
        String secretKeyDir = documentDir + "/SSOQuestimed/";
        String secretKeyFile = secretKeyDir + "SecretKey";
        try {
            //read secretKey from file
            FileInputStream fis = new FileInputStream(secretKeyFile);
            byte[] keybyte = new byte[16];
            fis.read(keybyte);
            fis.close();
            secretKey = new SecretKeySpec(keybyte, "AES");
        } catch (FileNotFoundException e1) {
            logger.info("SecretKey file not found, creating...");

            secretKey = generateAesEncryptionKey();

            try {
                //check if secretkey directory exists, if not, create it
                File skdir = new File(secretKeyDir);
                if (!skdir.exists()) {
                    skdir.mkdirs();
                }

                //write secretkey to file
                FileOutputStream fos = new FileOutputStream(secretKeyFile);
                fos.write(secretKey.getEncoded());
                fos.close();
            } catch (Exception e2) {
                logger.error("Cannot write secretKey to file", e2);
            }
        } catch (IOException e3) {
            logger.error("Cannot read secretKey file", e3);
        }
        return secretKey;
    }

    private static SecretKey generateAesEncryptionKey() {
        try {
            KeyGenerator keyGenerator = KeyGenerator.getInstance("AES");
            keyGenerator.init(128);
            return keyGenerator.generateKey();
        } catch (NoSuchAlgorithmException e) {
            logger.error("Error generating AES entryption key", e);
        }
        return null;
    }

    private static String encryptAes(SecretKey secretKey, String plainData) {
        try {
            byte[] b = null;
            if (plainData != null) {
                b = plainData.getBytes(MiscUtils.DEFAULT_UTF8_ENCODING);
            }
            byte[] encryptedData = encryptDecrypt("AES", Cipher.ENCRYPT_MODE, secretKey, b);

            return Base64.getEncoder().encodeToString(encryptedData);
        } catch (Exception e) {
            logger.error("Cannot encrypt", e);
        }
        return null;
    }

    private static String decryptAes(SecretKey secretKey, String encryptedDataStr) {
        try {
            byte[] encryptedData = Base64.getDecoder().decode(encryptedDataStr);

            byte[] b = encryptDecrypt("AES", Cipher.DECRYPT_MODE, secretKey, encryptedData);
            return (new String(b, MiscUtils.DEFAULT_UTF8_ENCODING));
        } catch (Exception e) {
            logger.error("Cannot decrypt", e);
        }
        return null;
    }

    private static byte[] encryptDecrypt(String algorithm, int cipherMode, Key key, byte[] data) throws Exception {
        if (key == null) {
            return (data);
        }

        Cipher cipher = Cipher.getInstance(algorithm);
        cipher.init(cipherMode, key);
        byte[] results = cipher.doFinal(data);
        return (results);
    }
}
