// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library LibENSEvents {
    event EnsRegistered(address user, string ensName);
    event DPUpdated(address user, string ensName);
}

library LibENSErrors {
    error EnsNotRegistered();
    error EnsAlreadyTaken();
    error NotEnsOwner();
}