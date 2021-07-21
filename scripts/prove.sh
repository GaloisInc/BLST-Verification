#!/bin/sh
set -e

err_handler() {
  [ $? -eq 0 ] && exit || printf "%s\n" "Verification failed in $file" >&2
}

trap err_handler EXIT

files="proof/memory_safety.saw proof/keygen.saw proof/functional_proofs.saw proof/x86/correctness_add.saw"

for f in $files; do
  file=$f
  saw "$f" -s "$(printf '%s' "build/${f}_output.json" | sed -e 's/\.saw//' -e 's!/proof/!/!')" -f json
done

echo "All functions under verification were verified successfully"
echo "Files processed:"
for f in $files; do
  echo "$f"
done
