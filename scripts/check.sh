#!/bin/sh

# Copyright (c) 2020 Galois, Inc.
# SPDX-License-Identifier: Apache-2.0 OR MIT

# There are two sorts of validation checks in the tests directory: property checks
# and test vectors from the specifications.
#
# Most of the validation properties are not easily provable with SMT solvers
# as they rely on some difficult algebraic properties, and the base types involved
# are far too large for the SMT solver to handle effectively.  So they are just tested
# with random values
#
# The test vectors are just evaluations of the functions on a small selection of
# arguments, with known answers. Whether we :prove or :check does not matter;
# the Cryptol iterpreter just evaluates them.

# Some long-running or memory-intensive checks are in a separate file.

cryptol --stop-on-error -b scripts/check.cryptol
