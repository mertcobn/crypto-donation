// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {Script} from "forge-std/Script.sol";
import {CryptoDonation} from "../src/CryptoDonation.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract CryptoDonationScript is Script {
    CryptoDonation public cryptoDonation;
    ERC1967Proxy public eRC1967Proxy;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        cryptoDonation = new CryptoDonation();
        eRC1967Proxy = new ERC1967Proxy(address(cryptoDonation), abi.encodeCall(CryptoDonation.initialize, ()));
        vm.stopBroadcast();
    }
}
