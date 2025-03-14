// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

contract SocialPeTransactions is Initializable, UUPSUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    
    struct Action {
        address user;
        string actionType;
        uint256 timestamp;
    }

    mapping(uint256 => Action) public actions;
    uint256 public actionCount;

    mapping(string => bool) public allowedActions;
    mapping(address => bool) public registeredUsers;

    event ActionRecorded(address indexed user, string actionType, uint256 timestamp);
    event ActionTypeAdded(string actionType);
    event UserRegistered(address indexed user);

    function initialize() public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        __Context_init();
        __ReentrancyGuard_init();
        actionCount = 0;
    }

    /// @notice Admin registers a user (Only registered users can transact)
    function registerUser(address user) external onlyOwner {
        require(!registeredUsers[user], "User already registered");
        registeredUsers[user] = true;
        emit UserRegistered(user);
    }

    /// @notice Admin adds a new action type dynamically
    function addActionType(string calldata actionType) external onlyOwner {
        require(!allowedActions[actionType], "Action type already exists");
        allowedActions[actionType] = true;
        emit ActionTypeAdded(actionType);
    }

    /// @notice Users can record actions ONLY if registered
    function recordAction(address user, string calldata actionType) external nonReentrant {
        require(registeredUsers[user], "User not registered");
        require(allowedActions[actionType], "Invalid action type");

        actions[actionCount] = Action(user, actionType, block.timestamp);
        emit ActionRecorded(user, actionType, block.timestamp);
        actionCount++;
    }

    /// @dev Restricts upgrades to the owner
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function _msgSender() internal view override(ContextUpgradeable) returns (address) {
        return ContextUpgradeable._msgSender();
    }

    function _msgData() internal view override(ContextUpgradeable) returns (bytes calldata) {
        return ContextUpgradeable._msgData();
    }
}
