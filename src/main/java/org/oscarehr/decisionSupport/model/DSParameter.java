/*
*
* Copyright (c) 2001-2002. Centre for Research on Inner City Health, St. Michael's Hospital, Toronto. All Rights Reserved. *
* This software is published under the GPL GNU General Public License.
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License
* as published by the Free Software Foundation; either version 2
* of the License, or (at your option) any later version. *
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details. * * You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. *
*
* <OSCAR TEAM>
*
* This software was written for
* Centre for Research on Inner City Health, St. Michael's Hospital,
* Toronto, Ontario, Canada
*/

package org.oscarehr.decisionSupport.model;

/**
 *
 * @author rjonasz
 */
public class DSParameter {
    private String strClass;
    private String strAlias;

    /**
     * @return the strClass
     */
    public String getStrClass() {
        return strClass;
    }

    /**
     * @param strClass the strClass to set
     */
    public void setStrClass(String strClass) {
        this.strClass = strClass;
    }

    /**
     * @return the strAlias
     */
    public String getStrAlias() {
        return strAlias;
    }

    /**
     * @param strAlias the strAlias to set
     */
    public void setStrAlias(String strAlias) {
        this.strAlias = strAlias;
    }
}