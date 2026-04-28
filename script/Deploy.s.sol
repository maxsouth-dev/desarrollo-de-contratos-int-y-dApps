// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {MyToken} from "../src/MyToken.sol";

/// @title DeployMyToken
/// @notice Script to deploy MyToken
/// @dev Run with: forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast --account dev-wallet
contract DeployMyToken is Script {
    function run() external returns (MyToken) {
        vm.startBroadcast();

        MyToken token = new MyToken();

        vm.stopBroadcast();

        console.log("MyToken deployed at:", address(token));
        console.log("Initial supply:", token.totalSupply());
        console.log("Owner:", token.owner());

        return token;
    }
}
