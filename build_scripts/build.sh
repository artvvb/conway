#!/bin/bash
vivado -mode batch -source $(dirname $0)/build.tcl -tclargs $1