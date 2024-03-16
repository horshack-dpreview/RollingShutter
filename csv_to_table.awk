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
    print "<table id=\"readout_times\" class=\"stripe compact cell-border order-column hover nowrap\" style=\"width:100%; border: 1px solid black; box-shadow: 4px 4px 4px gray; background-color:#fffff5;\">"
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
        print "\t\t<tr>"
        for (i=1; i<=NF; i++) {
            if (i==1)
                # first column is camera name. convert into a link of same name that links to detailed measurements
                print "\t\t\t<td><a href=\"#"$i"\">"$i"</a></td>"
            else
                print "\t\t\t<td>"$i"</td>"
        }
        print "\t\t</tr>"
        numRowsPrinted++
    }
}
END {
    if (numRowsPrinted > 0) {
        print "\t</tbody>"
        print "</table>"
    }
}

