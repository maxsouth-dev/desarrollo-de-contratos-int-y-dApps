// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {AcademicCredentials} from "../src/AcademicCredentials.sol";

/// @title DeployAcademicCredentials
/// @notice Deploys the AcademicCredentials registry. The deployer becomes the issuer.
/// @dev    Run with:
///         forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast --account dev-wallet
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
