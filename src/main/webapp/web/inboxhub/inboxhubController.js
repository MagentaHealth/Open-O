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

//Opens a popup window to a given inbox item.
function reportWindow(page, height, width) {
    if (height && width) {
        windowprops = "height=" + height + ", width=" + width + ", location=no, scrollbars=yes, menubars=no, toolbars=no, resizable=yes, top=0, left=0";
    } else {
        windowprops = "height=660, width=960, location=no, scrollbars=yes, menubars=no, toolbars=no, resizable=yes, top=0, left=0";
    }
    var popup = window.open(encodeURI(page), "labreport", windowprops);
    popup.focus();
}
//Data table custom sorting to move empty or null slots on any selected sort to the bottom.
jQuery.extend(jQuery.fn.dataTableExt.oSort, {
    "non-empty-string-asc": function (str1, str2) {
        if (str1 == "")
            return 1;
        if (str2 == "")
            return -1;
        return ((str1 < str2) ? -1 : ((str1 > str2) ? 1 : 0));
    },
    "non-empty-string-desc": function (str1, str2) {
        if (str1 == "")
            return 1;
        if (str2 == "")
            return -1;
        return ((str1 < str2) ? 1 : ((str1 > str2) ? -1 : 0));
    }
});

$(document).ready(function () {
    $('#inbox_table').DataTable({
        autoWidth: false,
        searching: false,
        scrollCollapse: true,
        paging: false,
        columnDefs: [
            {type: 'non-empty-string', targets: "_all"},
            {orderable: false, targets: 0}
        ],
        order: [[1, 'asc']],
    });
});

$(function () {
    $("#autocompleteProvider").autocomplete({
        source: contextPath + "/provider/SearchProvider.do?method=labSearch",
        minLength: 2,
        focus: function (event, ui) {
            $("#autocompleteProvider").val(ui.item.label);
            return false;
        },
        select: function (event, ui) {
            $("#autocompleteProvider").val(ui.item.label);
            $("#findProvider").val(ui.item.value);
            $(this).closest("form").submit();
            return false;
        }
    })
});