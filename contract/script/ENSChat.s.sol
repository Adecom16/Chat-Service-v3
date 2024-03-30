// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "../lib/forge-std/src/Script.sol";
import "../src/ChatSystem.sol";
import "../src/ENSNameService.sol";

contract ENSChatScript is Script {
    ENSNameService _nameService;
    ChatDapp _chatDapp;
    function setUp() public {}

    function run()  external {
        vm.startBroadcast();

        _nameService = new ENSNameService();

        _chatDapp = new ChatDapp(address(_nameService));

        console2.log(address(_nameService));
        console2.log(address(_chatDapp));
    

        vm.stopBroadcast();
    }
}
