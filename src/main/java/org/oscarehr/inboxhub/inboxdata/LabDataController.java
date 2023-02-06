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
import org.oscarehr.util.SpringUtils;
import oscar.oscarLab.ca.on.CommonLabResultData;
import oscar.oscarLab.ca.on.HRMResultsData;
import oscar.oscarLab.ca.on.LabResultData;

import java.util.ArrayList;

public class LabDataController {
    //Returns lab data based on the query. If none of the lab, doc, and hrm flags are set in the query, returns all data types.
    public static ArrayList<LabResultData> getLabData(LoggedInInfo loggedInInfo, InboxhubQuery query) {
        Integer page = 0;
        Integer pageSize = Integer.MAX_VALUE;
        //Whether to use the paging functionality. Currently setting this to false does not function and crashes the inbox.
        Boolean isPaged = true;
        Boolean mixLabsAndDocs = true;
        CommonLabResultData comLab = new CommonLabResultData();
        InboxResultsDao inboxResultsDao = (InboxResultsDao) SpringUtils.getBean("inboxResultsDao");
        ArrayList<LabResultData> labDocs = new ArrayList<LabResultData>();

        Boolean all = (!query.getDoc() && !query.getLab() && !query.getHrm());
        if (query.getDoc() || all) {
            labDocs.addAll(inboxResultsDao.populateDocumentResultsData(query.getSearchProviderNo(), query.getDemographicNo(), query.getPatientFirstName(),
                    query.getPatientLastName(), query.getPatientHealthNumber(), query.getStatus(), isPaged, page, pageSize, mixLabsAndDocs, query.getAbnormalBool(), query.getStartDate(), query.getEndDate()));
        }
        if (query.getLab() || all) {
            labDocs.addAll(comLab.populateLabResultsData(loggedInInfo,query.getSearchProviderNo(), query.getDemographicNo(), query.getPatientFirstName(),
                    query.getPatientLastName(), query.getPatientHealthNumber(), query.getStatus(), isPaged, page, pageSize, mixLabsAndDocs, query.getAbnormalBool(), query.getStartDate(), query.getEndDate()));
        }
        if (query.getHrm() || all) {
            HRMResultsData hrmResult = new HRMResultsData();
            labDocs.addAll(hrmResult.populateHRMdocumentsResultsData(loggedInInfo, query.getSearchProviderNo(), query.getPatientFirstName(),
                    query.getPatientLastName(), query.getPatientHealthNumber(), query.getDemographicNo(), query.getStatus(), query.getStartDate(), query.getEndDate(), isPaged, page, pageSize));
        }
        return labDocs;
    }
}
