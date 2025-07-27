#!/bin/bash
#
# CopyMetalLibrary.sh
# Aether
#
# Build phase script to compile and copy Metal shader library
#

# Exit on error
set -e

# Input and output paths
METAL_FILE="${SRCROOT}/aether/Resources/MetalShaderStub.metal"
AIR_FILE="${SRCROOT}/aether/Resources/MetalShaderStub.air"
METALLIB_FILE="${SRCROOT}/aether/Resources/default.metallib"
OUTPUT_METALLIB="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/default.metallib"

# Check if Metal file exists
if [ ! -f "$METAL_FILE" ]; then
    echo "Warning: Metal shader file not found at $METAL_FILE"
    exit 0
fi

# Compile Metal to AIR
echo "Compiling Metal shader..."
xcrun -sdk macosx metal -c "$METAL_FILE" -o "$AIR_FILE"

# Create Metal library
echo "Creating Metal library..."
xcrun -sdk macosx metallib "$AIR_FILE" -o "$METALLIB_FILE"

# Copy to app bundle
echo "Copying Metal library to app bundle..."
cp "$METALLIB_FILE" "$OUTPUT_METALLIB"

# Clean up intermediate files
rm -f "$AIR_FILE"

echo "Metal library build complete"