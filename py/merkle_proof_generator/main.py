#!/usr/bin/env python

import json
import argparse
import os
from typing import List
import eth2spec.deneb.mainnet as spec
from eth2spec.utils.ssz.ssz_impl import serialize
from remerkleable.core import Path
from remerkleable.tree import merkle_hash

def compute_merkle_witness(state, validator_index: int):
    """
    Compute the Merkle witness for a specific validator in the state.
    Returns the generalized index (gindex), root, and witness (proof).
    """
    print(f"Getting Merkle path for validator index {validator_index}")
    
    # Generate merkle path for the requested index
    merkle_path = Path(spec.BeaconState) / 'validators' / validator_index
    target_gindex = merkle_path.gindex()
    print("Target gindex (in binary):", bin(target_gindex))

    merkle_tree = state.get_backing()
    root = merkle_tree.merkle_root().hex()

    # Traverse to compute witness
    node = merkle_tree
    check_bit = 1 << (target_gindex.bit_length() - 2)
    print("Check bit:", bin(check_bit))
    witness = []
    while check_bit > 0:
        if check_bit & target_gindex != 0:  # follow bit path of target gindex
            witness.append("0x" + node.get_left().merkle_root().hex())
            node = node.get_right()
        else:
            witness.append("0x" + node.get_right().merkle_root().hex())
            node = node.get_left()
        check_bit >>= 1

    # Final value at the node
    value = node.merkle_root().hex()

    return {
        "gindex": target_gindex,
        "root": root,
        "witness": witness,
        "value": value
    }

def main():
    # Argument parser for CLI
    parser = argparse.ArgumentParser(description="Compute Merkle witness for validator in the BeaconState.")
    parser.add_argument('--validator-index', type=int, required=True, help="Validator index")
    parser.add_argument('--output-file', type=str, default="../data/proof.json", help="Output JSON file for the result")
    parser.add_argument('--beacon-state-file', type=str, default='../data/beacon_state_raw.ssz', help="Path to BeaconState file")
    
    args = parser.parse_args()

    # Load BeaconState from file
    beacon_state_file = args.beacon_state_file
    print(f"Loading BeaconState from {beacon_state_file}")
    
    state_size = os.stat(beacon_state_file).st_size
    print(f"Loading BeaconState of {state_size} bytes!")

    with open(beacon_state_file, "rb") as f:
        state = spec.BeaconState.deserialize(f, state_size)

    print("State loaded successfully!")

    # Compute Merkle witness for the validator index
    result = compute_merkle_witness(state, args.validator_index)

    # Output result to JSON file
    output_file = args.output_file
    with open(output_file, 'w') as f:
        json.dump(result, f, indent=4)

    print(f"Results written to {output_file}")

if __name__ == "__main__":
    main()
