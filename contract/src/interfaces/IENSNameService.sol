// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IENSNameService {
    struct DomainDetails {
        address owner;
        string ensName;
        string DisplayPictureURI;
    }
    function getEnsDetails(string memory _ensName) external view returns (address, string memory, string memory);
    function getAllRegisteredUsers() external view returns (DomainDetails[] memory);
}