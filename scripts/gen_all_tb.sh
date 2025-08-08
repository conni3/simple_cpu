#!/usr/bin/env bash
set -e

# Directory containing your individual testbenches
TB_DIR="tb"
# Output wrapper
OUT_FILE="$TB_DIR/all_tb.v"

# Header + module start
cat > "$OUT_FILE" <<EOF
\`timescale 1ns / 1ps

// Auto-generated top-level wrapper instantiating all testbenches
module all_tb;
EOF

# Loop over every *_tb.v in tb/, instantiate each module
for tb in "$TB_DIR"/*_tb.v; do
  mod=\$(basename "\$tb" .v)
  echo "  \$mod ${mod}_inst();" >> "\$OUT_FILE"
done

# Close the wrapper
cat >> "$OUT_FILE" <<EOF

endmodule
EOF

echo "✔ Generated \$OUT_FILE"
