/**
 * Copyright (c) 2023. Magenta Health Inc. All Rights Reserved.
 *
 * This software is published under the GPL GNU General Public License.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
 */
package org.oscarehr.inboxhub.query;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import java.util.Objects;

public class InboxhubQuery extends ActionForm {
    private Boolean viewMode;
    private Boolean clearFilters;
    private Boolean doc;
    private Boolean lab;
    private Boolean hrm;
    private Boolean unmatched;
    private String abnormal;
    private String searchAll;
    private String searchProviderName;
    private String searchProviderNo;
    private String demographicNo;
    private String patientFirstName;
    private String patientLastName;
    private String patientHealthNumber;
    private String status;
    private String startDate;
    private String endDate;

    public String getEndDate() {
        return endDate;
    }

    public void setEndDate(String endDate) {
        this.endDate = endDate;
    }

    public String getStartDate() {
        return startDate;
    }

    public void setStartDate(String startDate) {
        this.startDate = startDate;
    }

    public Boolean getUnmatched() {
        return unmatched;
    }

    public void setUnmatched(Boolean unmatched) {
        this.unmatched = unmatched;
    }

    public Boolean getClearFilters() {
        return clearFilters;
    }

    public void setClearFilters(Boolean clearFilters) {
        this.clearFilters = clearFilters;
    }

    public String getSearchProviderNo() {
        return searchProviderNo;
    }

    public String getSearchProviderName() {
        return searchProviderName;
    }

    public void setSearchAll(String searchAll) {
        this.searchAll = searchAll;
    }

    public String getSearchAll() {
        return searchAll;
    }

    public void setSearchProviderName(String searchProviderName) {
        this.searchProviderName = searchProviderName;
    }

    public void setSearchProviderNo(String searchProviderNo) {
        this.searchProviderNo = searchProviderNo;
    }

    public String getDemographicNo() {
        return demographicNo;
    }

    public void setDemographicNo(String demographicNo) {
        this.demographicNo = demographicNo;
    }

    public String getPatientFirstName() {
        return patientFirstName;
    }

    public void setPatientFirstName(String patientFirstName) {
        this.patientFirstName = patientFirstName;
    }

    public String getPatientLastName() {
        return patientLastName;
    }

    public void setPatientLastName(String patientLastName) {
        this.patientLastName = patientLastName;
    }

    public String getPatientHealthNumber() {
        return patientHealthNumber;
    }

    public void setPatientHealthNumber(String patientHealthNumber) {
        this.patientHealthNumber = patientHealthNumber;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Boolean getDoc() {
        return doc;
    }

    public void setDoc(Boolean doc) {
        this.doc = doc;
    }

    public Boolean getLab() {
        return lab;
    }

    public void setLab(Boolean lab) {
        this.lab = lab;
    }

    public Boolean getHrm() {
        return hrm;
    }

    public void setHrm(Boolean hrm) {
        this.hrm = hrm;
    }

    public String getAbnormal() {
        return abnormal;
    }

    public void setAbnormal(String abnormal) {
        this.abnormal = abnormal;
    }

    public Boolean getAbnormalBool() {
        return Objects.equals(abnormal, "All") ? null : Objects.equals(abnormal, "Normal") ? false : true;
    }

    public Boolean getViewMode() {
        return viewMode;
    }

    public void setViewMode(Boolean viewMode) {
        this.viewMode = viewMode;
    }

    @Override
    public void reset(ActionMapping mapping, HttpServletRequest request) {
        this.clearFilters = false;
        this.searchProviderName = "";
        this.searchProviderNo = "-1";
        this.demographicNo = null;
        this.patientFirstName = "";
        this.patientLastName = "";
        this.patientHealthNumber = "";
        this.status = "N";
        this.startDate = "";
        this.endDate = "";
        this.doc = false;
        this.lab = false;
        this.hrm = false;
        this.unmatched = false;
        this.abnormal = "All";
        this.searchAll = "";
        this.viewMode = false;
        super.reset(mapping, request);
    }

}
