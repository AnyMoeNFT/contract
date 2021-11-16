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

    modifier OnlyOwner() {
        require(_msgSender() == _owner, "only anymoe team is allowed");
        _;
    }

    constructor(address nft_address) {
        _owner = payable(_msgSender());
        _nft_contract_address = nft_address;
        _nft_contract = AnyMoeNFT(nft_address);
    }

    function InviteCreator() public virtual {
        
    }

    function RegisterCreator() public virtual {
        
    }

}