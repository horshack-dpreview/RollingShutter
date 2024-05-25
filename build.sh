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
soffice --headless --convert-to csv:"Text - txt - csv (StarCalc)":44,34,UTF8,1,,0,false,true,false,false,false,2 results/measurements.ods

#
# Run our awk script to convert the CSV into an HTML table formatted for use by 
# the datatables library (https://datatables.net/)
#
awk -f csv_to_table.awk 'measurements-Combined Results (Full-Sensor, ms).csv' > table.txt

#
# generate HTML for the full results spreadsheet (written to measurements.html), extracting only the body
# of the html (removing header/footer tags). We also convert the HTML anchors created by the conversion from
# anonymous values like table05 to values matching the sheet name, which allows us to create links to
# each camera-specific sheet
#
soffice --headless --convert-to html results/measurements.ods 
sed  '1,/<A NAME=/d' measurements.html  | sed -e 's/<a name="\(.*\)"><h1>.*<em>\(.*\)<\/em>.*/<a name="\2"<\/a>/i' | sed '/<\/body>/,$d' > all_measurements.html

#
# Insert results table, all measurements, other info to template html file and save as final index.html
#
sed -e '/<!-- TABLE -->/r table.txt' -e '/<!-- ALL_MEASUREMENTS -->/r all_measurements.html' -e "/<!-- LAST UPDATED -->/a Last Updated: $(date)" docs/index_template.html > docs/index.html

#
# generate json version of full-sensor readout measurements
# 
cat table.txt | ./html_table_to_json.py | jq .[]  > results/full_sensor.json

#
# Cleanup temporary files
#
rm table.txt
rm 'measurements-Combined Results (Full-Sensor, ms).csv' 
rm all_measurements.html
rm measurements.html
