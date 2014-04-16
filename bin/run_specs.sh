#!/bin/bash
# Run specs individually, to avoid interdependencies.
# Based on scripts from github.com/rspec/rspec-expectations

function run_specs_one_by_one {
  for file in `find spec -iname '*_spec.rb'`; do
    echo "rspec $file"
    rspec --backtrace $file
  done
}

run_specs_one_by_one

TEST_COVERAGE=true rspec --warnings
