// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {LibSort} from "solady/utils/LibSort.sol";
import {ConsensusLayerVerifier} from "../src/ConsensusLayerVerifier.sol";

contract ConsensusLayerVerifierTest is Test {
    // using stdJson for string;
    ConsensusLayerVerifier public verify;

    uint256 internal mainnetFork;
    string internal MAINNET_RPC_URL = vm.envString("ETH_RPC");

    ConsensusLayerVerifier.BeaconBlockHeader public header;

    // intermediatory struct to ingest json
    // note injested json is ordered alphabetically
    struct JsonHeader {
        bytes32 body_root;
        bytes32 parent_root;
        string proposer_index;
        string slot;
        bytes32 state_root;
    }

    struct JsonProof {
        uint256 gindex;
        bytes32 root;
        bytes32 value;
        bytes32[] witness;
    }

    JsonProof jsonProof;

    function setUp() public {
        string memory root = vm.projectRoot();
        string memory path = string.concat(
            root,
            "/data/beacon_block_header.json"
        );
        string memory json = vm.readFile(path);
        bytes memory data = vm.parseJson(json);
        JsonHeader memory jsonHeader = abi.decode(data, (JsonHeader));
        header = _convertHeaderStruct(jsonHeader);
        path = string.concat(root, "/data/proof.json");
        json = vm.readFile(path);
        data = vm.parseJson(json);
        jsonProof = abi.decode(data, (JsonProof));

        // fork mainnet to access beacon roots
        // fork at this block number so test data is not out of date (older than 1 day)
        mainnetFork = vm.createFork(MAINNET_RPC_URL, 20893945);
        vm.selectFork(mainnetFork);
        verify = new ConsensusLayerVerifier();
    }

    function testRootCall() public view {
        bytes32 root = verify.getParentBeaconBlockRoot(block.timestamp);
        assertTrue(root != bytes32(""));
    }

    function testVerifyHeader() public view {
        uint256 timestamp = (uint256(header.slot + 1) * 12) +
            verify.GENESIS_SLOT_TIMESTAMP();

        bytes32 headerRoot = verify.calculateBeaconHeaderMerkleRoot(header);
        bytes32 root = verify.getParentBeaconBlockRoot(timestamp);
        assertEq(headerRoot, root);
    }

    function testVerifyValidatorValidator() public view {
        // Validator index 123 @ slot 10103527
        bytes32 stateRoot = 0xc3c0e26f64feb8793e3fe8e9eab6b187b9dca0672e96df5de92746cad170803c;
        ConsensusLayerVerifier.Validator
            memory validator = ConsensusLayerVerifier.Validator({
                pubkey: hex"a9df2cfd79a8b569e7abc286047ade81dbc2e5b89bfd8c00b0913ba3c539b80ff469e77465c6d1815b29e151ab8efd38",
                withdrawalCredentials: 0x01000000000000000000000007982d9ece6ff05d7eaf38f3431a330d2f4a5233,
                effectiveBalance: 32000000000,
                slashed: false,
                activationEligibilityEpoch: 0,
                activationEpoch: 0,
                exitEpoch: 18446744073709551615,
                withdrawableEpoch: 18446744073709551615
            });
        bytes32[] memory proof = jsonProof.witness;
        LibSort.reverse(proof);
        // verify validator against state root
        bool valid = verify.verifyValidator(
            stateRoot,
            validator,
            proof,
            jsonProof.gindex
        );
        assertTrue(valid);
        // verify validator against roots contract
        valid = verify.verifyValidator(
            header,
            validator,
            proof,
            jsonProof.gindex
        );
        assertTrue(valid);
        // verify active against state root
        valid = verify.verifyValidatorActive(
            stateRoot,
            validator,
            proof,
            jsonProof.gindex
        );
        assertTrue(valid);
        // verify active against roots contract
        valid = verify.verifyValidatorActive(
            header,
            validator,
            proof,
            jsonProof.gindex
        );
        assertTrue(valid);
        // verify withdrawal address
        address withdrawalAddress = address(
            uint160(
                uint256(
                    0x01000000000000000000000007982d9ece6ff05d7eaf38f3431a330d2f4a5233
                )
            )
        );
        // verify against state root
        valid = verify.verifyValidatorWithdrawalAddress(
            stateRoot,
            validator,
            proof,
            jsonProof.gindex,
            withdrawalAddress
        );
        assertTrue(valid);
        // verify against roots contract
        valid = verify.verifyValidatorWithdrawalAddress(
            stateRoot,
            validator,
            proof,
            jsonProof.gindex,
            withdrawalAddress
        );
        assertTrue(valid);
    }

    // Helpers

    function stringToUint(string memory s) internal pure returns (uint result) {
        bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }

    function _convertHeaderStruct(
        JsonHeader memory jsonHeader
    )
        internal
        pure
        returns (ConsensusLayerVerifier.BeaconBlockHeader memory head)
    {
        head = ConsensusLayerVerifier.BeaconBlockHeader({
            slot: uint64(stringToUint(jsonHeader.slot)),
            proposerIndex: uint64(stringToUint(jsonHeader.proposer_index)),
            parentRoot: jsonHeader.parent_root,
            stateRoot: jsonHeader.state_root,
            bodyRoot: jsonHeader.body_root
        });
    }
}
