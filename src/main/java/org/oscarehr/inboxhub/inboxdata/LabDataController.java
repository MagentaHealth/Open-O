/*
 *Copyright (c) 2023. Magenta Health Inc. All Rights Reserved.
 *
 *This software is published under the GPL GNU General Public License.
 *
 *This program is free software; you can redistribute it and/or
 *modify it under the terms of the GNU General Public License
 *as published by the Free Software Foundation; either version 2
 *of the License, or (at your option) any later version.
 *This program is distributed in the hope that it will be useful,
 *but WITHOUT ANY WARRANTY; without even the implied warranty of
 *MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *GNU General Public License for more details.
 *
 *You should have received a copy of the GNU General Public License
 *along with this program; if not, write to the Free Software
 *Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
 */

package org.oscarehr.inboxhub.inboxdata;

import org.oscarehr.common.dao.InboxResultsDao;
import org.oscarehr.inboxhub.query.InboxhubQuery;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import oscar.oscarLab.ca.on.CommonLabResultData;
import oscar.oscarLab.ca.on.HRMResultsData;
import oscar.oscarLab.ca.on.LabResultData;
import oscar.oscarMDS.data.CategoryData;
import oscar.oscarMDS.data.ProviderData;

import java.sql.SQLException;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Objects;

public class LabDataController {

    //Converts given string date to date object. Returns null if not in yyyy-MM-dd format or blank.
    public static Date convertDate(String stringDate){
        if (!Objects.equals(stringDate, "")) {
            DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
            try {
                Date date = df.parse(stringDate);
                return date;
            } catch (ParseException e) {
                MiscUtils.getLogger().error(e);
                return null;
            }
        }
        return null;
    }
    //Gets inbox CategoryData for given query. CategoryData includes document counts for all document types & patient lists.
    public static CategoryData getCategoryData(InboxhubQuery query){
        Boolean patientSearch = false;
        Boolean providerSearch = true;
        if (Objects.equals(query.getSearchProviderNo(), "-1")) {
            providerSearch = false;
        }
        if (query.getDemographicNo() != null || !Objects.equals(query.getPatientFirstName(), "") || !Objects.equals(query.getPatientLastName(), "") || !Objects.equals(query.getPatientHealthNumber(), "")) {
            patientSearch = true;
        }

        CategoryData categoryData = new CategoryData(query.getPatientLastName(), query.getPatientFirstName(), query.getPatientHealthNumber(), patientSearch, providerSearch, query.getSearchProviderNo(), query.getStatus(), query.getAbnormal(), query.getStartDate(), query.getEndDate());
        try {
            categoryData.populateCountsAndPatients();
        } catch (SQLException e) {
            MiscUtils.getLogger().error(e);
        }
        return categoryData;
    }
    //Returns lab data based on the query. If lab, doc, and hrm flags are not set in the query returns all data from all data types.
    public static ArrayList<LabResultData> getLabData(LoggedInInfo loggedInInfo, InboxhubQuery query) {
        Integer page = 0;
        Integer pageSize = Integer.MAX_VALUE;
        Boolean isPaged = true;
        Boolean mixLabsAndDocs = true;
        Date startDate = convertDate(query.getStartDate());
        Date endDate= convertDate(query.getEndDate());
        String loggedInProviderNo = (String) loggedInInfo.getSession().getAttribute("user");
        String loggedInName = ProviderData.getProviderName(loggedInProviderNo);
        CommonLabResultData comLab = new CommonLabResultData();
        InboxResultsDao inboxResultsDao = (InboxResultsDao) SpringUtils.getBean("inboxResultsDao");
        ArrayList<LabResultData> labDocs = new ArrayList<LabResultData>();

        //Checking unclaimed vs claimed physician. If no searchAll/provider search filter is provided reset search to logged in provider.
        if (Objects.equals(query.getSearchAll(), "true")) {//All
            query.setSearchProviderNo("-1");
            query.setSearchProviderName("");
        }
        else if (Objects.equals(query.getSearchAll(), "false")) {
            query.setSearchProviderNo("0");
            query.setSearchProviderName("");
        }
        else if (Objects.equals(query.getSearchProviderNo(), "0") || Objects.equals(query.getSearchProviderNo(), "-1")) {
            query.setSearchProviderNo(loggedInProviderNo);
            query.setSearchProviderName(loggedInName);
        }

        //checking unmatched vs matched patient. Setting demographic number to 0 will grab inbox objects with no patient attached. This should overwrite all current patient queries.
        if (query.getUnmatched()){
            query.setDemographicNo("0");
            query.setPatientFirstName("");
            query.setPatientLastName("");
            query.setPatientHealthNumber("");
        }

        Boolean all = (!query.getDoc() && !query.getLab() && !query.getHrm());
        if (query.getDoc() || all) {
            labDocs.addAll(inboxResultsDao.populateDocumentResultsData(query.getSearchProviderNo(), query.getDemographicNo(), query.getPatientFirstName(),
                    query.getPatientLastName(), query.getPatientHealthNumber(), query.getStatus(), isPaged, page, pageSize, mixLabsAndDocs, query.getAbnormalBool(), startDate , endDate));
        }
        if (query.getLab() || all) {
            labDocs.addAll(comLab.populateLabResultsData(loggedInInfo,query.getSearchProviderNo(), query.getDemographicNo(), query.getPatientFirstName(),
                    query.getPatientLastName(), query.getPatientHealthNumber(), query.getStatus(), isPaged, page, pageSize, mixLabsAndDocs, query.getAbnormalBool(), startDate, endDate));
        }
        if (query.getHrm() || all) {
            HRMResultsData hrmResult = new HRMResultsData();
            labDocs.addAll(hrmResult.populateHRMdocumentsResultsData(loggedInInfo, query.getSearchProviderNo(), query.getPatientFirstName(),
                    query.getPatientLastName(), query.getPatientHealthNumber(), query.getDemographicNo(), query.getStatus(), startDate, endDate, isPaged, page, pageSize));
        }
        return labDocs;
    }
}
