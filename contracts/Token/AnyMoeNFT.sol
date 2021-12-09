// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.4;

import "./ERC1155.sol";

contract AnyMoeNFT is ERC1155 {
    
    uint256 private tokenCount = 0x0;

    address private _creatorContract;

    event MintNFT(address indexed creator, address indexed to, uint256 id, uint256 amount, string uri);

    constructor(address creatorContract) ERC1155() {
        _creatorContract = creatorContract;
    }

    modifier OnlyCreatorContract {
        require(_msgSender() == _creatorContract, "only creator contract is allowed");
        _;
    }
    
    function changeCreatorContract(address target) OnlyCreatorContract public {
        _creatorContract = target;
    }
    
    function mintNFT(
        address creator,
        address to,
        uint256 amount,
        string memory uri
    ) OnlyCreatorContract public virtual {
        _mintNFT(creator, to, tokenCount, uri, amount, "");
        emit MintNFT(creator, to, tokenCount, amount, uri);
        tokenCount ++;
    }
    
}