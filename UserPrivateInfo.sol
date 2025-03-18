// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@coti-io/coti-contracts/contracts/access/DataPrivacyFramework/extensions/DataPrivacyFrameworkMpc.sol";
//import "@coti-io/coti-contracts/contracts/access/DataPrivacyFramework/DataPrivacyFramework.sol";

contract UserPrivateInfo is DataPrivacyFrameworkMpc {
    // Struct to store encrypted user information
    struct UserInfo {
        gtString name;
        gtString email;
        bool isRegistered;
    }

    // Mapping to store user information
    mapping(address => UserInfo) private userInfos;

    // Events
    event UserRegistered(address indexed userAddress);
    event UserInfoUpdated(address indexed userAddress);

    constructor() DataPrivacyFrameworkMpc(false, false) {}

    // Function to register new user
    function registerUser(
        gtString calldata _name,
        gtString calldata _email,
        uint256 uintParameter,
        address addressParameter,
        string calldata stringParameter
    ) external {
        require(!userInfos[msg.sender].isRegistered, "User already registered");

        UserInfo storage newUser = userInfos[msg.sender];
        newUser.name = _name;
        newUser.email = _email;
        newUser.isRegistered = true;

        emit UserRegistered(msg.sender);
    }

    // Function to update user information
    function updateUserInfo(
        gtString calldata _name,
        gtString calldata _email,
        uint256 uintParameter,
        address addressParameter,
        string calldata stringParameter
    ) external {
        require(userInfos[msg.sender].isRegistered, "User not registered");

        UserInfo storage user = userInfos[msg.sender];
        user.name = _name;
        user.email = _email;

        emit UserInfoUpdated(msg.sender);
    }

    // Function to check if user is registered
    function isUserRegistered(address userAddress) external view returns (bool) {
        return userInfos[userAddress].isRegistered;
    }

    // Function to get user information (only accessible by the user themselves)
    function getUserInfo(
        uint256 uintParameter,
        address addressParameter,
        string calldata stringParameter
    ) external view returns (gtString memory, gtString memory) {
        require(userInfos[msg.sender].isRegistered, "User not registered");
        
        UserInfo storage user = userInfos[msg.sender];
        return (user.name, user.email);
    }
} 
