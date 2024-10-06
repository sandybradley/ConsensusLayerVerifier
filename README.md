# Consensus Layer Verifier

The `ConsensusLayerVerifier` smart contract is designed to verify data from the Ethereum Beacon chain by using Merkle hashing techniques. It reconstructs the beacon block root, which can be queried on-chain via the Beacon Roots contract (EIP-4788).

This repository consists of three main components:
1. **Solidity Contract (`ConsensusLayerVerifier.sol`)**: Implements the logic to verify Beacon block headers, state roots, and validator data using Merkle proofs.
2. **Bash Script**: A shell script to interact with the Beacon node API and retrieve the latest Beacon chain state.
3. **Python Script**: Generates Merkle proofs required for verifying the Beacon state and validator information.

## Table of Contents
- [Contract Overview](#contract-overview)
- [Functions](#functions)
  - [Merkle Root Calculation](#merkle-root-calculation)
  - [Beacon Block Header Verification](#beacon-block-header-verification)
  - [Validator Verification](#validator-verification)
- [External Components](#external-components)
  - [Bash Script](#bash-script)
  - [Python Script](#python-script)
- [Getting Started](#getting-started)
  - [Installation](#installation)
  - [Usage](#usage)
- [Foundry](#foundry)

## Contract Overview

The `ConsensusLayerVerifier` contract provides functionalities for verifying various components of the Beacon chain, including:
- **Beacon Block Header**: Verifies the Merkle root of the Beacon block header.
- **State Root**: Verifies the Merkle proof of a state root within the Beacon block.
- **Validator**: Verifies validator information (e.g., balance, withdrawal credentials) by computing the Merkle root and checking it against the Beacon state.

### External Libraries
- **MerkleTree**: A library for Merkle tree calculations.
- **EndianHelper**: A library for handling endian-specific operations.

## Functions

### Merkle Root Calculation
The contract contains functions to calculate and verify Merkle roots for Beacon block headers and validator data.

- **`calculateBeaconHeaderMerkleRoot`**: Computes the Merkle root of a Beacon block header.
- **`verifyBeaconHeaderMerkleRoot`**: Verifies the Merkle root of a given block header against a stored Beacon root.
- **`calculateValidatorMerkleRoot`**: Calculates the Merkle root of a given validator.

### Beacon Block Header Verification
The contract verifies the integrity of a Beacon block header by checking it against the Beacon Roots contract (`EIP-4788`).

- **`getParentBeaconBlockRoot`**: Fetches the Beacon block root at a given timestamp.
- **`verifyBeaconHeaderMerkleRoot`**: Validates that the Merkleized header matches the Beacon block root on-chain.

### Validator Verification
Validator data (such as balance, withdrawal address, and slashing status) can be verified against the Beacon state root.

- **`verifyValidator`**: Verifies a validator's data using a Merkle proof.
- **`verifyValidatorWithdrawalAddress`**: Confirms the withdrawal address of a validator.
- **`verifyValidatorActive`**: Checks if a validator is active and not slashed.

## External Components

### Bash Scripts

The repository includes bash scripts that retrieve the latest Beacon chain state from a Beacon node API. This data can be used to fetch block roots and other state information necessary for verification.

**Get latest beacon block header**:
```bash
./script/get_beacon_block.sh
```

**Get latest beacon state (warning: ~700 MB download)**:
```bash
./script/get_latest_beacon_state.sh
```

### Python Script
The Python script in this repository is used to generate Merkle proofs required for verifying various data (e.g., state roots, validator information) against the Beacon block root.

**Generate merkle proof for a validator**:
```bash
cd py
python run merkle_proof_generator/main.py
```

This script is essential for creating the Merkle proofs that are input into the smart contract for verification.

**Merkle Tree Proof of Verification**

To prove that a specific field in a validator's record (e.g., `withdrawal_credentials`) is part of the BeaconState Merkle tree, we traverse the tree and collect witness nodes (sibling hashes) along the path from the leaf node to the root.

The Merkle witness nodes are used to recompute the Merkle root and verify that the value is included in the tree.

```plaintext
                ROOT
                 │
          ┌──────┴──────┐
          │             │
     Hash0              Hash1
      │                   │
  ┌───┴───┐           ┌───┴───┐
  │       │           │       │
Leaf0   Leaf1      Leaf2    Leaf3
```
**Example Path and Witness**

Suppose we're interested in verifying the value of a field (e.g., withdrawal_credentials) at Leaf2. The verification process involves:

- Locate Leaf2: The target value in the Merkle tree.
- Collect Witness Nodes: Gather sibling hashes along the path from Leaf2 to the root. These sibling hashes (known as the Merkle witness) are:
  - Hash of Leaf3 (sibling of Leaf2).
  - Hash of Hash0 (sibling of Hash1).
- Compute Root: Using the Leaf2 value and the collected witness nodes, we compute the Merkle root and compare it with the known root of the tree. If they match, the value is verified.

```plaintext

                  Root (Verified)
                    ▲
                    │
   Witness: Hash0 ──┘
                    │
        ┌───────────┴───────────┐
        │                       │
   Leaf2 (value)     Witness: Leaf3
```
Witness Nodes Explanation

- Leaf2: This is the value we want to verify.
- Leaf3: The sibling of Leaf2, used to compute Hash1.
- Hash0: The sibling of Hash1, used to compute the Merkle root.

By traversing up the tree, the verification process ensures that the target value is part of the overall BeaconState structure.

## Getting Started
### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-repo/consensus-layer-verifier.git
cd consensus-layer-verifier
```
2. Set environment variables
e.g.
```bash
export ETH_RPC="https://eth.llamarpc.com"
export BEACON_RPC="https://beacon-nd-422-757-666.p2pify.com/0a9d79d93fb2f4a4b1e04695da2b77a7"
```
3. Get latest beacon header and or beacon state
```bash
./script/get_beacon_block.sh
```
4. Run tests
```bash
forge test -vvv
```

### Usage
1. **Deploy the contract:** Deploy the `ConsensusLayerVerifier.sol` contract on your local or test network.
2. **Use the Bash script:** Fetch the latest Beacon chain state from your node:
```bash
./script/get_latest_beacon_state.sh
```
3. **Generate Merkle proofs:** Use the Python script to generate proofs for specific block headers or validators:
```bash
cd py
python run generate_merkle_proof/main.py --validator-index <index>
```    
4. **Verify data on-chain:** Call the contract functions to verify headers, state roots, and validator data.

## Credits 

https://github.com/Layr-Labs/eigenlayer-contracts/blob/dev/src/contracts/libraries/BeaconChainProofs.sol

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
