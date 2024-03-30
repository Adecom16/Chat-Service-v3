// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import {ENSNameService} from "../src/ENSNameService.sol";

import {LibENSErrors, LibENSEvents} from "../src/libraries/LibENSNameService.sol";

contract NameServiceTest is Test {
    ENSNameService nameServiceContract;

    address A = address(0xa);
    address B = address(0xb);
    address C = address(0xc);

    function setUp() public {
        nameServiceContract = new ENSNameService();

        A = mkaddr("user A");
        B = mkaddr("user B");
        C = mkaddr("user C");
    }

    function testRegisterNameService() public {
        switchSigner(A);

        nameServiceContract.registerNameService("test", "test");
        assert(nameServiceContract.nameToAddress("test") != address(0));

        (string memory _domainName, , address _owner) = nameServiceContract
            .getEnsDetails("test");
        assert(
            keccak256(abi.encodePacked(_domainName)) ==
                keccak256(abi.encodePacked("test"))
        );
        assert(_owner == A);
    }

    function testRegisterNameServiceEmitEvent() public {
        switchSigner(A);

        // assert event emitted
        vm.expectEmit(true, true, false, false);
        emit LibENSEvents.EnsRegistered(A, "test");
        emit LibENSEvents.DPUpdated(A, "test");
        nameServiceContract.registerNameService("test", "test");
    }

    function testRegisterNameTwiceRevert() public {
        switchSigner(A);

        nameServiceContract.registerNameService("test", "test");

        switchSigner(B);
        // assert revert
        vm.expectRevert(
            abi.encodeWithSelector(LibENSErrors.EnsAlreadyTaken.selector)
        );
        nameServiceContract.registerNameService("test", "avatarTest");
    }

    function testGetDomainDetails() public {
        switchSigner(A);
        nameServiceContract.registerNameService("test", "test");

        (
            string memory _domainName,
            string memory _avatarURI,
            address _owner
        ) = nameServiceContract.getEnsDetails("test");

        assert(
            keccak256(abi.encodePacked(_domainName)) ==
                keccak256(abi.encodePacked("test"))
        );
        assert(
            keccak256(abi.encodePacked(_avatarURI)) ==
                keccak256(abi.encodePacked("test"))
        );
        assert(_owner == A);
    }

    function testGetDomainDetailsFailForUnregisteredDomains() public {
        vm.expectRevert(
            abi.encodeWithSelector(LibENSErrors.EnsNotRegistered.selector)
        );
        nameServiceContract.getEnsDetails("test");
    }

    function testUpdateAvatarURI() public {
        switchSigner(A);
        nameServiceContract.registerNameService("test", "test");

        nameServiceContract.updateEnsDP("test", "ipfs://newAvatar.jpg");

        (, string memory _avatarURI, ) = nameServiceContract.getEnsDetails(
            "test"
        );

        assert(
            keccak256(abi.encodePacked(_avatarURI)) ==
                keccak256(abi.encodePacked("ipfs://newAvatar.jpg"))
        );
    }
    function testUpdateAvatarURIFailWhenCalledForDomainNotOwned() public {
        nameServiceContract.registerNameService("test", "test");

        switchSigner(A);

        vm.expectRevert(
            abi.encodeWithSelector(LibENSErrors.NotEnsOwner.selector)
        );
        nameServiceContract.updateEnsDP("test", "ipfs://newAvatar.jpg");
    }

    function testUpdateAvatarURIFailForUnregigsteredDomains() public {
        switchSigner(A);

        vm.expectRevert(
            abi.encodeWithSelector(LibENSErrors.EnsNotRegistered.selector)
        );
        nameServiceContract.updateEnsDP("test", "ipfs://newAvatar.jpg");
    }

    function switchSigner(address _newSigner) public {
        address foundrySigner = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
        if (msg.sender == foundrySigner) {
            vm.startPrank(_newSigner);
        } else {
            vm.stopPrank();
            vm.startPrank(_newSigner);
        }
    }

    function mkaddr(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        return addr;
    }
}