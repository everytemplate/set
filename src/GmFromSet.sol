// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "pre-std/interfaces/ISetProvider.sol";
import "pre-std/interfaces/IMintableSet.sol";
import "pre-std/utils/Set.sol";

contract GmFromSet is IMintableSet, ISetProvider, Set {
    error NoSpecifyingId();
    error NotImplemented();

    address _setRegistry;
    address _kindRegistry;
    address _relRegistry;
    uint64 _kind;

    constructor() Set("", msg.sender) {
        _kind = 18;
    }

    function mint(uint64 id) external override returns (uint64) {
        if (id != 0) revert NoSpecifyingId();
        id = _nextId();
        ObjectMeta memory meta = ObjectMeta({rev: 1, krev: 1, srev: 1, cap: 0, kind: _kind, set: _self});
        bytes32[] memory state = new bytes32[](0);
        _create(id, meta, state, msg.sender);
        emit URI(_pimUri(id, meta.rev), uint256(id));
        return id;
    }

    function mint(uint64, /*id*/ bytes memory /*input*/ ) external pure override returns (uint64) {
        revert NotImplemented();
    }

    function onRegister(
        address setRegistry,
        address kindRegistry,
        address relRegistry,
        address owner,
        uint64 universe,
        uint64 self,
        string memory baseUri
    ) external override returns (bytes4) {
        __Set_init(owner, universe, self, baseUri);
        _setRegistry = setRegistry;
        _kindRegistry = kindRegistry;
        _relRegistry = relRegistry;
        return ISetProvider.onRegister.selector;
    }

    function onTouch(uint64 /*id*/ ) external pure override returns (bytes4) {
        return ISetProvider.onTouch.selector;
    }

    function onTransfer(uint64, /*id*/ address, /*from*/ address /*to*/ ) external pure override returns (bytes4) {
        return ISetProvider.onTransfer.selector;
    }
}
