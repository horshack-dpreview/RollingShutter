#!/bin/bash

#
# builds HTML files in /docs that are served by GitHub Pages for our project
#

#
# Generate a CSV from the combined-results sheet #2 in the measurement spreadsheet.
# The CSV will be named same as the sheet's tab: 'measurements-Combined Results (ms).csv'
#
# Ref: https://wiki.documentfoundation.org/ReleaseNotes/7.2#Document_Conversion
#
soffice --headless --convert-to csv:"Text - txt - csv (StarCalc)":44,34,UTF8,1,,0,false,true,false,false,false,2 measurements.ods

#
# Run our awk script to convert the CSV into an HTML table formatted for use by 
# the datatables library (https://datatables.net/)
#
awk -f csv_to_table.awk 'measurements-Combined Results (ms).csv' > table.txt


#
# Add results table to skeleton index.html source, saving output to temp1.html
#
sed '/<!-- TABLE -->/r table.txt' docs/index_template.html > temp1.html

#
# generate HTML for the full results spreadsheet (written to measurements.html), extracting only the body
# of the html (removing header/footer tags) and also renaming some elements within the body
#
soffice --headless --convert-to html measurements.ods 
sed  '1,/<body>/d' measurements.html  | sed -e 's/Overview/Detailed Results/' -e '/Sheet/d' | sed '/<\/body>/,$d' > all_measurements.html

#
# Add full results to temp1.html, saving output to final docs/index.html
#
sed '/<!-- ALL_MEASUREMENTS -->/r all_measurements.html' temp1.html > docs/index.html


#
# Cleanup temporary files
#
rm table.txt
rm 'measurements-Combined Results (ms).csv' 
rm temp1.html
rm all_measurements.html
rm measurements.html
