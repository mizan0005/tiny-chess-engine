// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title AgentIdentityRegistry
/// @notice Minimal self-service registry binding a human-readable Agent ID to a wallet.
contract AgentIdentityRegistry {
    struct Identity {
        address wallet;
        string metadataURI;
        uint64 registeredAt;
        bool active;
    }

    mapping(bytes32 => Identity) private identities;
    mapping(address => bytes32) public walletToAgent;
    event AgentRegistered(bytes32 indexed agentIdHash, string agentId, address indexed wallet, string metadataURI);
    event MetadataUpdated(bytes32 indexed agentIdHash, string metadataURI);
    event WalletChanged(bytes32 indexed agentIdHash, address indexed oldWallet, address indexed newWallet);
    event AgentDeactivated(bytes32 indexed agentIdHash, address indexed wallet);

    error EmptyAgentId();
    error AlreadyRegistered();
    error NotIdentityOwner();
    error WalletAlreadyLinked();
    error ZeroAddress();
    error IdentityInactive();

    function register(string calldata agentId, string calldata metadataURI) external {
        bytes32 id = _hash(agentId);
        if (bytes(agentId).length == 0) revert EmptyAgentId();
        if (identities[id].active) revert AlreadyRegistered();
        if (walletToAgent[msg.sender] != bytes32(0)) revert WalletAlreadyLinked();
        identities[id] = Identity(msg.sender, metadataURI, uint64(block.timestamp), true);
        walletToAgent[msg.sender] = id;
        emit AgentRegistered(id, agentId, msg.sender, metadataURI);
    }

    function updateMetadata(string calldata agentId, string calldata metadataURI) external {
        bytes32 id = _hash(agentId);
        Identity storage item = identities[id];
        if (!item.active) revert IdentityInactive();
        if (item.wallet != msg.sender) revert NotIdentityOwner();
        item.metadataURI = metadataURI;
        emit MetadataUpdated(id, metadataURI);
    }

    function transferIdentity(string calldata agentId, address newWallet) external {
        bytes32 id = _hash(agentId);
        Identity storage item = identities[id];
        if (!item.active) revert IdentityInactive();
        if (item.wallet != msg.sender) revert NotIdentityOwner();
        if (newWallet == address(0)) revert ZeroAddress();
        if (walletToAgent[newWallet] != bytes32(0)) revert WalletAlreadyLinked();
        address old = item.wallet;
        delete walletToAgent[old];
        walletToAgent[newWallet] = id;
        item.wallet = newWallet;
        emit WalletChanged(id, old, newWallet);
    }

    function deactivate(string calldata agentId) external {
        bytes32 id = _hash(agentId);
        Identity storage item = identities[id];
        if (!item.active) revert IdentityInactive();
        if (item.wallet != msg.sender) revert NotIdentityOwner();
        item.active = false;
        delete walletToAgent[msg.sender];
        emit AgentDeactivated(id, msg.sender);
    }

    function getIdentity(string calldata agentId) external view returns (
        address wallet, string memory metadataURI, uint64 registeredAt, bool active
    ) {
        Identity memory item = identities[_hash(agentId)];
        return (item.wallet, item.metadataURI, item.registeredAt, item.active);
    }

    function _hash(string calldata agentId) private pure returns (bytes32) {
        return keccak256(bytes(agentId));
    }
}
