#!/bin/bash
# Description: Setup environment for zk_ecdsa project and generate inputs for Noir circuit

# ============================
# 1. Hash the message
# ============================
# Example message
MESSAGE="hello"

# Hash the message using Foundry's cast
export HASHED_MESSAGE=$(cast keccak "$MESSAGE")
echo "Hashed message: $HASHED_MESSAGE"

# ============================
# 2. Generate a wallet
# ============================
# Create new wallet
WALLET_INFO=$(cast wallet new)
echo "$WALLET_INFO"

# Extract private key
export PRIV_KEY=$(echo "$WALLET_INFO" | grep "Private key" | awk '{print $3}')
echo "Private key exported to PRIV_KEY"

# ============================
# 3. Get the public key
# ============================
PUB_KEY_FULL=$(cast wallet pubkey --private-key "$PRIV_KEY")
export PUB_KEY="$PUB_KEY_FULL"
echo "Full public key: $PUB_KEY"

# ============================
# 4. Split public key into X/Y
# ============================
# Remove '0x' and split
PUB_KEY_NO0X=${PUB_KEY#0x}
export PUB_KEY_X="0x${PUB_KEY_NO0X:0:64}"
export PUB_KEY_Y="0x${PUB_KEY_NO0X:64:64}"
echo "PUB_KEY_X: $PUB_KEY_X"
echo "PUB_KEY_Y: $PUB_KEY_Y"

# ============================
# 5. Sign the hashed message
# ============================
SIGNATURE=$(cast wallet sign --no-hash --private-key "$PRIV_KEY" "$HASHED_MESSAGE")
# Strip last byte (v) if necessary
SIGNATURE_NO_V=${SIGNATURE:0:${#SIGNATURE}-2}
export SIGNATURE="$SIGNATURE_NO_V"
echo "Signature (r+s): $SIGNATURE"

# ============================
# 6. Generate Prover.toml inputs for Noir
# ============================
chmod +x generate_inputs.sh
./generate_inputs.sh
echo "Prover.toml generated"

# ============================
# 7. Run Noir circuit and witness
# ============================
nargo execute
echo "Noir circuit executed, witness generated"

# ============================
# 8. Generate proof using Barretenberg
# ============================
bb prove -b ./target/ecdsa.json -w ./target/ecdsa.gz -o ./target
echo "Proof generated"

bb write_vk -b ./target/ecdsa.json -o ./target
echo "Verification key written"

bb verify -k ./target/vk -p ./target/proof
echo "Proof verified successfully"
