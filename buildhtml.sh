#!/bin/bash

#
# builds HTML files in /docs that are served by GitHub Pages for our project
#

#
# Generate a CSV from the combinedr-esults sheet #2 in the measurement spreadsheet.
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
# Construct index.html from the template source file, merging in the generated results table
#
sed '/<!-- TABLE -->/r table.txt' docs/index_template.html > docs/index.html

#
# Cleanup temporary files
#
rm table.txt
rm 'measurements-Combined Results (ms).csv' 

