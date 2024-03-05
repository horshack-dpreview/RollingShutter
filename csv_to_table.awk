#!/bin/awk -f

#
# converts CSV exported from our results spreadsheet into an HTML table formatted
# for use by the datatables library (https://datatables.net/)
#

BEGIN {
    FS=","
    printingTable=0
    numRowsPrinted=0
}
/Model/ { # we start processing when we see the header line of the exported CSV
    printingTable=1
    print "<table id=\"readout_times\" class=\"stripe\" style=\"width:100%\">"
    print "\t<thead>"
    print "\t\t<tr>"
    for (i=1; i<=NF; i++)
        print "\t\t\t<th>"$i"</th>"
    print "\t\t</tr>"
    print "\t</thead>"
    next
}
{
    # generate an HTML table row for each exported CSV line
    if (printingTable > 0) {
        if (numRowsPrinted == 0) {
            # printing first row - insert a <tbody>
            print "\t<tbody>"
        }
        numRowsPrinted++
        print "\t\t<tr>"
        for (i=1; i<=NF; i++)
            print "\t\t\t<td>"$i"</td>"
        print "\t\t</tr>"
    }
}
END {
    if (numRowsPrinted > 0) {
        print "\t</tbody>"
        print "</table>"
    }
}

