#!/bin/bash

output_file="Prover.toml"

# Convert hex string (without 0x) to quoted decimal byte array
hex_to_dec_quoted_array() {
    local hexstr=$1
    local len=${#hexstr}
    local arr=()
    for (( i=0; i<len; i+=2 )); do
        # Extract two hex digits
        local hexbyte="${hexstr:i:2}"
        # Convert hex to decimal number
        local dec=$((16#$hexbyte))
        # Add decimal number as quoted string
        arr+=("\"$dec\"")
    done
    echo "["$(IFS=,; echo "${arr[*]}")"]"
}

# Read values from environment variables
# Make sure the env vars are set: HASHED_MESSAGE, PUB_KEY_X, PUB_KEY_Y, SIGNATURE
if [ -z "$HASHED_MESSAGE" ] || [ -z "$PUB_KEY_X" ] || [ -z "$PUB_KEY_Y" ] || [ -z "$SIGNATURE" ]; then
    echo "Please set HASHED_MESSAGE, PUB_KEY_X, PUB_KEY_Y, and SIGNATURE environment variables."
    exit 1
fi

hashed_message=${HASHED_MESSAGE#0x}
pub_key_x=${PUB_KEY_X#0x}
pub_key_y=${PUB_KEY_Y#0x}
signature=${SIGNATURE#0x}

# Strip last byte (2 hex chars) from signature to remove v
signature=${signature:0:${#signature}-2}

# Convert hex strings to decimal quoted arrays
hashed_message_arr=$(hex_to_dec_quoted_array "$hashed_message")
pub_key_x_arr=$(hex_to_dec_quoted_array "$pub_key_x")
pub_key_y_arr=$(hex_to_dec_quoted_array "$pub_key_y")
signature_arr=$(hex_to_dec_quoted_array "$signature")

# Write output
cat > "$output_file" <<EOF
hashed_message = $hashed_message_arr
pub_key_x = $pub_key_x_arr
pub_key_y = $pub_key_y_arr
signature = $signature_arr
EOF

echo "Wrote $output_file"
