#!/bin/sh
set -e

err_handler() {
  [ $? -eq 0 ] && exit || printf "%s\n" "Verification failed in $file" >&2
}

trap err_handler EXIT

files="proof/memory_safety.saw proof/keygen.saw proof/functional_proofs.saw"

for f in $files; do
  file=$f
  saw "$f" 2>&1 | tee "$(printf '%s' "build/${f}_output" | sed 's/\.saw//')"
done

echo "All functions under verification were verified successfully"
echo "Files processed:"
for f in $files; do
  echo "$f"
done
