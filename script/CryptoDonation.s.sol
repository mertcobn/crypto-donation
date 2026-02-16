// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.33;

import {Script} from "forge-std/Script.sol";
import {CryptoDonation} from "../src/CryptoDonation.sol";

contract CryptoDonationScript is Script {
    CryptoDonation public cryptoDonation;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        cryptoDonation = new CryptoDonation();

        vm.stopBroadcast();
    }
}
