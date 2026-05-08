#!/bin/bash

# Script to replace all package:togetherly/ imports with package:vesper/
# and all TogetherlyColors with VesperColors

echo "Updating package imports and color references..."

# Replace package imports
find /hologram/data/workspace/project/lib -name "*.dart" -type f -exec sed -i 's/package:togetherly\//package:vesper\//g' {} +

# Replace TogetherlyColors class references  
find /hologram/data/workspace/project/lib -name "*.dart" -type f -exec sed -i 's/TogetherlyColors/VesperColors/g' {} +

echo "All files updated!"
echo "Counting changes made..."

# Count files with vesper imports
echo "Files with package:vesper/ imports:"
grep -r "package:vesper/" /hologram/data/workspace/project/lib --include="*.dart" | wc -l

echo "Files with VesperColors references:"
grep -r "VesperColors" /hologram/data/workspace/project/lib --include="*.dart" | wc -l