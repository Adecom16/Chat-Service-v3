// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IENSNameService.sol";

contract ChatDapp {
    struct Message {
        address sender;
        address receiver;
        string content;
    }

    mapping(address => mapping(address => Message[])) chatHistory;

    event MessageSent(
        address indexed sender,
        address indexed receiver,
        string content
    );

    IENSNameService public nameService;

    constructor(address _nameServiceAddress) {
        nameService = IENSNameService(_nameServiceAddress);
    }

    function sendMessage(string memory _receiverEnsName, string memory _content) external {
        // Get receiver's details from NameService
        (address receiverAddress, , ) = nameService.getEnsDetails(_receiverEnsName);
        require(receiverAddress != address(0), "Receiver not registered");

        Message memory _message = Message(
            msg.sender,
            receiverAddress,
            _content
        );
        chatHistory[msg.sender][receiverAddress].push(_message);

        emit MessageSent(msg.sender, receiverAddress, _content);
    }

    function getMessages(string memory _senderEnsName, string memory _receiverEnsName)
        external
        view
        returns (Message[] memory)
    {
        // Get sender's and receiver's details from NameService
        (address senderAddress, , ) = nameService.getEnsDetails(_senderEnsName);
        require(senderAddress != address(0), "Sender not registered");

        (address receiverAddress, , ) = nameService.getEnsDetails(_receiverEnsName);
        require(receiverAddress != address(0), "Receiver not registered");

        return chatHistory[msg.sender][receiverAddress];
    }

    function getRegisteredUsers() external view returns (string[] memory) {
        IENSNameService.DomainDetails[] memory userDetails = nameService.getAllRegisteredUsers();
        string[] memory userNames = new string[](userDetails.length);

        for (uint256 i = 0; i < userDetails.length; i++) {
            userNames[i] = userDetails[i].ensName;
        }

        return userNames;
    }
}
