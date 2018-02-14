#!/bin/bash

echo 'print_processes.' | swipl --quiet abstraction_rules.pl | grep -v '^[ \t]*$' | grep -v '^false\.$'
