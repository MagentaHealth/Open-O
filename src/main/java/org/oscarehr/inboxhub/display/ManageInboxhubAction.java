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
package org.oscarehr.inboxhub.display;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;

import org.oscarehr.inboxhub.inboxdata.LabDataController;
import org.oscarehr.inboxhub.query.InboxhubQuery;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;
import oscar.oscarLab.ca.on.LabResultData;
import oscar.oscarMDS.data.CategoryData;

import java.util.*;

public class ManageInboxhubAction extends DispatchAction {
    private InboxhubQuery query;
    private ArrayList<LabResultData> labDocs;
    private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);

    public ActionForward undefined(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        return mapping.findForward("error");
    }

    public ActionForward displayInboxView(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
        if (!securityInfoManager.hasPrivilege(loggedInInfo, "_lab", SecurityInfoManager.READ, null)) {
            return mapping.findForward("unauthorized");
        }

        String page = request.getParameter("page");
        String pageSize = request.getParameter("pageSize");
        query.setPage(Integer.parseInt(page));
        query.setPageSize(Integer.parseInt(pageSize));

        LabDataController labDataController = new LabDataController();
        labDocs = labDataController.getLabData(loggedInInfo, query);
        if (labDocs.size() > 0) {
            String providerNo = request.getSession().getAttribute("user").toString();
            ArrayList<String> labLinks = labDataController.getLabLink(labDocs, query, request.getContextPath(), providerNo);
            request.setAttribute("labLinks", labLinks);
        }
        request.setAttribute("page", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("hasMoreViewData", labDocs.size() > 0);
        request.setAttribute("searchProviderNo", query.getSearchProviderNo());
        request.setAttribute("labDocs", labDocs);

        return mapping.findForward("displayView");
    }

    public ActionForward displayInboxForm(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        LabDataController labDataController = new LabDataController();
        LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
        String unclaimed = (String) request.getAttribute("unclaimed");
        if (!securityInfoManager.hasPrivilege(loggedInInfo, "_lab", SecurityInfoManager.READ, null)) {
            return mapping.findForward("unauthorized");
        }
        query = (InboxhubQuery) form;
        request.setAttribute("query", query);
        if (query.getClearFilters()) {
            query.reset(mapping, request);
        }
        
        labDataController.sanitizeInboxFormQuery(loggedInInfo, query);
        CategoryData categoryData = labDataController.getCategoryData(query);
        if (Objects.equals(unclaimed, "1")) {
            query.reset(mapping,request);
            query.setSearchProviderNo("0");
            query.setStatus("N");
            request.setAttribute("unclaimed","0");
        }
        request.setAttribute("viewMode", query.getViewMode());
        request.setAttribute("categoryData", categoryData);
        return mapping.findForward("success");
    }

    public ActionForward displayInboxList(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
        if (!securityInfoManager.hasPrivilege(loggedInInfo, "_lab", SecurityInfoManager.READ, null)) {
            return mapping.findForward("unauthorized");
        }

        String page = request.getParameter("page");
        String pageSize = request.getParameter("pageSize");
        query.setPage(Integer.parseInt(page));
        query.setPageSize(Integer.parseInt(pageSize));

        LabDataController labDataController = new LabDataController();
        labDocs = labDataController.getLabData(loggedInInfo, query);
        if (labDocs.size() > 0) {
            String providerNo = request.getSession().getAttribute("user").toString();
            ArrayList<String> labLinks = labDataController.getLabLink(labDocs, query, request.getContextPath(), providerNo);
            request.setAttribute("labLinks", labLinks);
        }
        request.setAttribute("page", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("hasMoreListData", labDocs.size() > 0);
        request.setAttribute("labDocs", labDocs);
        return mapping.findForward("displayList");
    }
}
 