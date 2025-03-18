// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@coti-io/coti-contracts/contracts/utils/mpc/MpcCore.sol";

contract UserInfo {
    struct User {
        utString name;
        utString email;
        bool isRegistered;
    }

    mapping(address => User) private users;

    event UserRegistered(address indexed userAddress);
    event UserUpdated(address indexed userAddress);

    constructor() {}

    function registerUser(itString calldata name, itString calldata email) external {
        require(!users[msg.sender].isRegistered, "User already registered");

        // Validate and process the encrypted name
        gtString memory nameGarbled = MpcCore.validateCiphertext(name);
        gtString memory emailGarbled = MpcCore.validateCiphertext(email);

        // Store the encrypted data with both network and user encryption
        users[msg.sender].name = MpcCore.offBoardCombined(nameGarbled, msg.sender);
        users[msg.sender].email = MpcCore.offBoardCombined(emailGarbled, msg.sender);
        users[msg.sender].isRegistered = true;

        emit UserRegistered(msg.sender);
    }

    function updateUser(itString calldata name, itString calldata email) external {
        require(users[msg.sender].isRegistered, "User not registered");

        // Validate and process the encrypted data
        gtString memory nameGarbled = MpcCore.validateCiphertext(name);
        gtString memory emailGarbled = MpcCore.validateCiphertext(email);

        // Update the encrypted data
        users[msg.sender].name = MpcCore.offBoardCombined(nameGarbled, msg.sender);
        users[msg.sender].email = MpcCore.offBoardCombined(emailGarbled, msg.sender);

        emit UserUpdated(msg.sender);
    }

    function getUserInfo() external view returns (ctString memory name, ctString memory email) {
        require(users[msg.sender].isRegistered, "User not registered");
        
        // Return only user-encrypted data (not network-encrypted)
        return (
            users[msg.sender].name.userCiphertext,
            users[msg.sender].email.userCiphertext
        );
    }

    function isUserRegistered(address userAddress) external view returns (bool) {
        return users[userAddress].isRegistered;
    }
} 
