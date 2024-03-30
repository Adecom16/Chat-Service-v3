// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {LibENSErrors, LibENSEvents} from "./libraries/LibENSNameService.sol";

contract ENSNameService {
    struct DomainDetails {
        string ensName;
        string DisplayPictureURI;
        address owner;
    }

    mapping(string => address) public nameToAddress;
    mapping(string => DomainDetails) public domains;
    string[] public registeredNames; // Array to store registered names

    function getEnsDetails(
        string memory _ensName
    ) public view returns (string memory, string memory, address) {
        if (nameToAddress[_ensName] == address(0)) {
            revert LibENSErrors.EnsNotRegistered();
        }

        return (
            domains[_ensName].ensName,
            domains[_ensName].DisplayPictureURI,
            domains[_ensName].owner
        );
    }

    function registerNameService(
        string memory _ensName,
        string memory _displayPictureURI
    ) public {
        if (nameToAddress[_ensName] != address(0)) {
            revert LibENSErrors.EnsAlreadyTaken();
        }
        nameToAddress[_ensName] = msg.sender;
        domains[_ensName] = DomainDetails(
            _ensName,
            _displayPictureURI,
            msg.sender
        );
        registeredNames.push(_ensName); // Add to registered names array

        emit LibENSEvents.EnsRegistered(msg.sender, _ensName);
    }

    function updateEnsDP(
        string memory _ensName,
        string memory _displayPictureURI
    ) public {
        if (nameToAddress[_ensName] == address(0)) {
            revert LibENSErrors.EnsNotRegistered();
        }
        if (nameToAddress[_ensName] != msg.sender) {
            revert LibENSErrors.NotEnsOwner();
        }

        domains[_ensName].DisplayPictureURI = _displayPictureURI;
        emit LibENSEvents.DPUpdated(msg.sender, _ensName);
    }

    function updateUserName(
        string memory _ensName,
        string memory _userName
    ) public {
        if (nameToAddress[_ensName] == address(0)) {
            revert LibENSErrors.EnsNotRegistered();
        }
        if (nameToAddress[_ensName] != msg.sender) {
            revert LibENSErrors.NotEnsOwner();
        }

        domains[_ensName].DisplayPictureURI = _userName;
        emit LibENSEvents.DPUpdated(msg.sender, _ensName);
    }

    function getAllRegisteredUsers() public view returns (string[] memory) {
        return registeredNames;
    }
}
