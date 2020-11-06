#!/bin/sh
set -e

err_handler () {
    [ $? -eq 0 ] && exit
    echo "Verification failed in $file"
}

trap err_handler EXIT

files="proof/memory_safety.saw proof/keygen.saw"

for f in $files; do
  file=$f
  saw $f
done

echo "All functions under verification were verified successfully"
echo "Files processed:"
for f in $files; do
  echo $f
done
