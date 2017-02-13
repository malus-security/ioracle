#!/bin/bash

echo 'print_sandboxAssignments.' | swipl --quiet abstraction_rules.pl | grep -v '^[ \t]*$' | grep -v '^false\.$'
