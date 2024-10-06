# BeaconState Merkle Witness Generator

This Python script computes the Merkle witness for specific validator in the Ethereum BeaconState. It extracts a Merkle path to a validator, computes the generalized index (gindex), and retrieves the root and witness (proof). The results are written to a JSON file for easy consumption and inspection.

## Features
- Computes the Merkle path for any validator in the Ethereum BeaconState.
- Outputs the generalized index, root, witness, and final value in JSON format.
- Flexible input parameters: validator index and output file location.

## Requirements

The script uses the Ethereum consensus specs and remerkleable libraries for tree and state operations. You'll need to install the following dependencies:

```bash
pip install eth2spec remerkleable
```

## Usage
### Command-Line Arguments

- `--validator-index` (required): The index of the validator in the BeaconState.
- `--output-file` (optional): Path to the output JSON file where the results will be written. Defaults to output.json.
- `--beacon-state-file` (optional): Path to the BeaconState file in SSZ format. Defaults to ../data/beacon_state_raw.ssz.

### Example

To compute the Merkle witness for validator index 123 and save the result to result.json:

```bash

python merkle_proof_generator/main.py --validator-index 123 --output-file result.json
```
### Output

The result will be written to the specified JSON file. Example output format:

```json

{
    "gindex": 1986,
    "root": "f8a1e2f03388bfa2cb12ab4bf7ff1b75b24cdb63b0308768b2e40f6364e2025b",
    "witness": [
        "fa97f6623b831c9aa4d416c51b4764e70d61b4eb77dfe6a5b51a50b7e8740b44",
        "67d51e0fcf5ebf4e4b4602fbb0d54d65bbdc8cb6bb10248efb87d7d156c4c828"
    ],
    "value": "f8a1e2f03388bfa2cb12ab4bf7ff1b75b24cdb63b0308768b2e40f6364e2025b"
}
```
### Additional Options

    You can specify a custom path to the BeaconState file using the --beacon-state-file argument:

## Prerequisites

Before running the script, ensure you have:

- Python 3.9 installed (`eth2spec` is brittle for installations of other versions)
- Required dependencies installed using `pip install eth2spec remerkleable`.

The script assumes that a BeaconState file (in SSZ format) is available in ../data/beacon_state_raw.ssz, but you can provide a custom path using the --beacon-state-file argument.

## Credits

https://github.com/ethereum/consensus-specs/issues/2179

## License

This project is licensed under the MIT License.