/*
 *  Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved. *
 *  This software is published under the GPL GNU General Public License.
 *  This program is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License
 *  as published by the Free Software Foundation; either version 2
 *  of the License, or (at your option) any later version. *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details. * * You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. *
 *
 *  Jason Gallagher
 *
 *  This software was written for the
 *  Department of Family Medicine
 *  McMaster University
 *  Hamilton
 *  Ontario, Canada   
 *
 * SortHashtable.java
 *
 * Created on May 29, 2006, 3:05 PM
 *
 */

package oscar.oscarLab;

import java.util.Comparator;
import java.util.Date;
import java.util.Hashtable;

/**
 * Used to sort a list of Lab hashtable objects 
 * @author jay
 */
public class SortHashtable implements Comparator {
    
    /** Creates a new instance of SortHashtable */
    public SortHashtable() {
    }

    public int compare(Object object, Object object0) {
        int ret  = 0;
        
        Date date1 = (Date) ((Hashtable) object).get("collDateDate");
        Date date2 = (Date) ((Hashtable) object0).get("collDateDate");;
        if (date1.after(date2)){
            ret = -1;
        }else if(date1.before(date2)){
            ret = 1;    
        }
        return ret;
    }
    
}