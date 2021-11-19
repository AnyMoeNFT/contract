// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.4;

import "../Token/AnyMoeNFT.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract AnyMoeCreator is Context {
    using Address for address;

    address payable private _owner;

    address private _nft_contract_address;
    AnyMoeNFT private _nft_contract;

    uint8 private _invitedThreshold;
    uint64 private _inviteThreshold;

    struct CreatorInfo {
        uint8 invited;
        mapping(address => bool) inviter;
        uint64 inviteCount;
        string info;
    }

    mapping(address => CreatorInfo) private _creators;

    event Invited(address from, address target);
    event InfoUpdated(address creator);

    modifier OnlyOwner() {
        require(_msgSender() == _owner, "only anymoe team is allowed");
        _;
    }

    constructor(uint8 invitedThreshold, uint64 inviteThreshold) {
        _owner = payable(_msgSender());
        _creators[_owner].invited = invitedThreshold;
        _invitedThreshold = invitedThreshold;
        _inviteThreshold = inviteThreshold;
    }

    function setNFTContractAddress(address nft_address) OnlyOwner public {
        _nft_contract_address = nft_address;
        _nft_contract = AnyMoeNFT(nft_address);
    }

    function setThreshold(uint8 invitedThreshold, uint64 inviteThreshold) OnlyOwner public {
        _invitedThreshold = invitedThreshold;
        _inviteThreshold = inviteThreshold;
    }

    function adminInvite(address target) OnlyOwner public {
        _creators[target].invited = _invitedThreshold;
    }

    function isInvited(address target) view public returns(bool) {
        return _creators[target].invited >= _invitedThreshold;
    }

    function invitedCount(address target) view public returns(uint8) {
        return _creators[target].invited
    }

    function inviteCount(address target) view public returns(uint64) {
        return _creators[target].inviteCount
    }

    function canInviteMore(address target) view public returns(bool) {
        return _creators[target].inviteCount <= _inviteThreshold;
    }

    function isInvitedBy(address target, address inviter) view public returns(bool) {
        return _creators[target].inviter[inviter];
    }

    function creatorInfo(address target) view public returns(string) {
        return _creators[target].info
    }

    function inviteCreator(address target) public virtual {
        require(target != address(0), "zero address");
        address operator = _msgSender();
        require(_creators[operator].invited >= _invitedThreshold, "permission denied");
        require(_creators[operator].inviteCount <= _inviteThreshold, "cant invite more");
        require(_creators[target].invited < _invitedThreshold, "already invited");
        require(!_creators[target].inviter[operator], "invited");
        _creators[operator].inviteCount += 1;
        _creators[target].invited += 1;
        _creators[target].inviter[operator] = true;
        emit Invited(operator, target);
    }

    function updateCreator(string memory uri) public virtual {
        address operator = _msgSender();
        require(_creators[operator].invited >= _invitedThreshold, "permission denied");
        _creators[operator].info = uri;
        emit InfoUpdated(operator);
    }

    function mintNFT(address to, uint256 amount, string memory uri) public virtual {
        address operator = _msgSender();
        require(_creators[operator].invited >= _invitedThreshold, "permission denied");
        _nft_contract.mintNFT(operator, to, amount, uri);
    }

}