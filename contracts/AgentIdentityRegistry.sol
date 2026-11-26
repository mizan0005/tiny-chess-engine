// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Minimal ERC-721 interface for the official Binance/SPACE ID Agent ID contract.
interface IAgentId {
    function balanceOf(address owner) external view returns (uint256);
}

/// @title AgentIdentityRegistry
/// @notice Agent ID-holder-gated profile registry for the Tiny Chess project.
/// @dev Registration is restricted to wallets holding at least one official Agent ID NFT.
///      The user-supplied agentId string is a profile label; it is NOT independently
///      resolved to or cryptographically proven as the NFT's name by this contract.
contract AgentIdentityRegistry {
    // Official SPACE ID Agent ID ERC-721 contract on BNB Chain (per Binance hackathon docs).
    IAgentId public constant AGENT_ID_CONTRACT =
        IAgentId(0x60b9262456de011f7d15a54cdd8c48baaa8b022f);

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
    error AgentIdRequired();

    /// @notice Returns true when a wallet holds at least one official Agent ID NFT.
    function hasAgentId(address wallet) public view returns (bool) {
        return AGENT_ID_CONTRACT.balanceOf(wallet) > 0;
    }

    function register(string calldata agentId, string calldata metadataURI) external {
        if (!hasAgentId(msg.sender)) revert AgentIdRequired();

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
