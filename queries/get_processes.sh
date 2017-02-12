#!/bin/bash

echo 'print_processes.' | swipl --quiet basic_rules.pl | grep -v '^[ \t]*$' | grep -v '^false\.$'
