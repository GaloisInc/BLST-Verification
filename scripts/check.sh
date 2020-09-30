#!/bin/bash

# Most of these validation properties are more provable woth SMT solvers
# as they rely on some difficult algebraic properties, and the base types involved
# are far too large fopr the SMT solver to handle effectively.  So they are just tested
# with random values, or with test vectors from the specification.

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

# long-running and a big memory footprint:
cryptol <<EOF
:set tests=100
:l tests/PairingTest.cry
:check
EOF
