// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ConsensusLayerVerifier} from "../src/ConsensusLayerVerifier.sol";

contract ConsensusLayerVerifierScript is Script {
    ConsensusLayerVerifier public verify;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        verify = new ConsensusLayerVerifier();

        vm.stopBroadcast();
    }
}
