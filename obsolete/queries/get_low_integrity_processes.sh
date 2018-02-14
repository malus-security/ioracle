#!/bin/bash

echo 'print_low_integrity_processes.' | swipl --quiet abstraction_rules.pl | grep -v '^[ \t]*$' | grep -v '^false\.$'
