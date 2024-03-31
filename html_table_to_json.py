#!/usr/bin/env python

#
# converts an HTML table from stdin to JSON stdout
#
# Relies on html_to_json: pip install html-to-json
#

import html_to_json
import json
import sys

html_string = sys.stdin.read()
tables = html_to_json.convert_tables(html_string)
print(json.dumps(tables))
