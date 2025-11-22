// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Set1155Linked, Descriptor} from "@everyprotocol/periphery/sets/Set1155Linked.sol";

/// @title DiceSet1155
/// @notice Example set for dice, implemented as an ERC1155-compatible set.
contract DiceSet1155 is Set1155Linked {
    error KindNotSpecified();
    error KindRevUnavailable();
    error SetNotRegistered();
    error ZeroSetRegistry();
    error ObjectIdAutoOnly();

    uint64 private _minted;
    uint64 private _kindId;
    uint32 private _kindRev;

    /// @param setRegistry Address of the SetRegistry this set will be linked to.
    /// @param kindId      Kind ID for dice objects.
    /// @param kindRev     Requested kind revision (0 = latest).
    constructor(address setRegistry, uint64 kindId, uint32 kindRev) {
        if (setRegistry == address(0)) revert ZeroSetRegistry();
        if (kindId == 0) revert KindNotSpecified();

        _Set1155Linked_initializeFrom(setRegistry);
        _kindId = kindId;
        _kindRev = kindRev;
    }

    /// @notice Mint a new dice object with an automatically assigned ID.
    function mint(
        address to,
        uint64 id0,
        bytes calldata /* data */
    )
        external
        returns (uint64 id, Descriptor memory desc)
    {
        // Auto-allocate object ID
        if (id0 != 0) revert ObjectIdAutoOnly();
        id = ++_minted;

        // The set must be registered; setId/setRev come from the registry.
        (uint64 setId, uint32 setRev) = Set1155Linked.getSetIdRev();
        if (setId == 0 || setRev == 0) revert SetNotRegistered();

        // Resolve the effective kind revision from KindRegistry.
        // _kindRev == 0 means "use the latest revision".
        uint32 kindRev = Set1155Linked.checkKindRev(_kindId, _kindRev);
        if (kindRev == 0) revert KindRevUnavailable();

        // All objects start at revision 1.
        desc = Descriptor({traits: 0, rev: 1, setRev: setRev, kindRev: kindRev, kindId: _kindId, setId: setId});

        // Single-element payload:
        // We treat the right-most byte as a random-ish integer n,
        // and the dice face is computed in the kind contract as (n % 6 + 1).
        bytes32[] memory elems = new bytes32[](1);
        elems[0] = _random();

        // Store first revision snapshot...
        _create(to, id, desc, elems);
        // ...and emit events (including ERC1155 events).
        _postCreate(to, id, desc, elems);
    }

    /// @notice "Roll" an existing dice object by updating its element.
    function roll(uint64 id) external returns (Descriptor memory desc) {
        // Update elements; descriptor.rev is incremented, other fields stay the same.
        bytes32[] memory elems = new bytes32[](1);
        elems[0] = _random();

        // Store the new revision...
        desc = _update(id, elems);
        // ...and emit events (including ERC1155 events).
        _postUpdate(id, desc, elems);
    }

    /// @dev Pseudo-random element generator for demo purposes only.
    ///      NOT suitable for production randomness.
    function _random() internal view returns (bytes32) {
        // forge-lint: disable-next-item(asm-keccak256)
        return keccak256(abi.encodePacked(block.prevrandao, tx.origin, gasleft()));
    }
}
