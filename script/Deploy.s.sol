// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {AcademicCredentials} from "../src/AcademicCredentials.sol";

/// @title DeployAcademicCredentials
/// @notice Deploys the AcademicCredentials registry. The deployer becomes the issuer.
/// @dev    Run with (requires .env, see .env.example):
///         source .env
///         forge script script/Deploy.s.sol --rpc-url $BASE_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
contract DeployAcademicCredentials is Script {
    function run() external returns (AcademicCredentials) {
        vm.startBroadcast();

        AcademicCredentials credentials = new AcademicCredentials();

        vm.stopBroadcast();

        console.log("AcademicCredentials deployed at:", address(credentials));
        console.log("Admin (deployer):", msg.sender);

        return credentials;
    }
}
