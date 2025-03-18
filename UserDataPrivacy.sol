// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@coti-io/coti-contracts/contracts/access/DataPrivacyFramework/DataPrivacyFramework.sol";

contract UserDataPrivacy is DataPrivacyFramework {
    // Structure to store user personal information
    struct UserInfo {
        string name;
        string email;
        bool isActive;
        uint256 createdAt;
    }

    // Mapping to store user information
    mapping(address => UserInfo) private userInfo;
    
    // Events
    event UserRegistered(address indexed userAddress);
    event UserUpdated(address indexed userAddress);
    event UserDeactivated(address indexed userAddress);

    constructor() DataPrivacyFramework(false, false) {
        // Initialize with restrictive permissions
        // Add allowed operations
        addAllowedOperation("register");
        addAllowedOperation("update");
        addAllowedOperation("deactivate");
        addAllowedOperation("read");
    }

    /**
     * @notice Register a new user with their personal information
     * @param name User's full name
     * @param email User's email address
     */
    function registerUser(
        string memory name,
        string memory email
    ) 
        external 
        onlyAllowedUserOperation("register", 0, address(0), "")
    {
        require(userInfo[msg.sender].createdAt == 0, "User already registered");
        require(bytes(name).length > 0, "Name cannot be empty");
        require(bytes(email).length > 0, "Email cannot be empty");

        userInfo[msg.sender] = UserInfo({
            name: name,
            email: email,
            isActive: true,
            createdAt: block.timestamp
        });

        emit UserRegistered(msg.sender);
    }

    /**
     * @notice Update user's personal information
     * @param name New name (optional, pass empty string to keep current)
     * @param email New email (optional, pass empty string to keep current)
     */
    function updateUser(
        string memory name,
        string memory email
    ) 
        external 
        onlyAllowedUserOperation("update", 0, address(0), "")
    {
        require(userInfo[msg.sender].createdAt > 0, "User not registered");
        require(userInfo[msg.sender].isActive, "User is not active");

        UserInfo storage user = userInfo[msg.sender];
        
        if (bytes(name).length > 0) {
            user.name = name;
        }
        if (bytes(email).length > 0) {
            user.email = email;
        }

        emit UserUpdated(msg.sender);
    }

    /**
     * @notice Deactivate user account
     */
    function deactivateUser() 
        external 
        onlyAllowedUserOperation("deactivate", 0, address(0), "")
    {
        require(userInfo[msg.sender].createdAt > 0, "User not registered");
        require(userInfo[msg.sender].isActive, "User already deactivated");

        userInfo[msg.sender].isActive = false;
        emit UserDeactivated(msg.sender);
    }

    /**
     * @notice Get user information
     * @param userAddress Address of the user
     * @return name User's name
     * @return email User's email
     * @return isActive User's active status
     * @return createdAt User's registration timestamp
     */
    function getUserInfo(address userAddress)
        external
        view
        onlyAllowedUserOperation("read", 0, userAddress, "")
        returns (
            string memory name,
            string memory email,
            bool isActive,
            uint256 createdAt
        )
    {
        require(userInfo[userAddress].createdAt > 0, "User not registered");
        UserInfo storage user = userInfo[userAddress];
        return (user.name, user.email, user.isActive, user.createdAt);
    }
} 
