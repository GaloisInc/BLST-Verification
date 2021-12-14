#!/bin/sh
set -e

err_handler() {
  [ $? -eq 0 ] && exit || printf "%s\n" "Verification failed in $file" >&2
}

trap err_handler EXIT

argfiles=$1
defaultfiles="proof/memory_safety.saw proof/functional_proofs.saw proof/correctness_add.saw proof/bulk_addition.saw"
files="${argfiles:=$defaultfiles}"

for f in $files; do
  file=$f
  summary_file=$(printf '%s' "build/${f}_output.json" | sed -e 's/\.saw//' -e 's!/proof/!/!')
  if [ "$f" = "proof/bulk_addition.saw" ]; then
    patch -f -p1 -t < patches/blst_bulk_addition_saw_cryptol/changes.patch
  fi
  saw "$f" -s "$summary_file" -f json
  python3 scripts/html_summary.py "$summary_file" -o "build/$(basename $f)_dependencies.html"
done

echo "All functions under verification were verified successfully"
echo "Files processed:"
for f in $files; do
  echo "$f"
done
