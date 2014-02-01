#!/bin/bash
# Run specs individually, to avoid interdependencies.
# Based on scripts from github.com/rspec/rspec-expectations

function run_specs_one_by_one {
  for file in `find spec -iname '*_spec.rb'`; do
    echo "rspec $file"
    rspec -b $file
  done
}

run_specs_one_by_one

COVERALLS=true rspec
