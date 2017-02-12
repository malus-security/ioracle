#!/bin/bash

echo 'print_high_integrity_processes.' | swipl --quiet test_abstraction.pl | grep -v '^[ \t]*$' | grep -v '^false\.$'
