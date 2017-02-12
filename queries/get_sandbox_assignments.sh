#!/bin/bash

echo 'print_sandboxAssignments.' | swipl --quiet basic_rules.pl | grep -v '^[ \t]*$' | grep -v '^false\.$'
