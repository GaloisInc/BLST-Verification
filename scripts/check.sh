#!/bin/bash

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

cryptol <<EOF
:set tests=100
:l tests/PolynomialTest.cry
:check
:l tests/ParameterTests.cry
:check
:l tests/ShortWeierstrassCurveTests.cry
:check
:l tests/ParameterTests.cry
:check
:l tests/HashToCurveE1Tests.cry
:check
:l tests/HashToCurveE2Tests.cry
:check
:l tests/FrobeniusTests.cry
:set tests=10
:check
:set tests=100
EOF
