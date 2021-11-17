// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.4;

import "./ERC1155.sol";

contract AnyMoeNFT is ERC1155 {
    
    uint256 private tokenCount = 0x0;

    address private _creatorContract;

    constructor(address creatorContract) ERC1155() {
        _creatorContract = creatorContract;
    }

    modifier OnlyCreatorContract {
        require(_msgSender() == _creatorContract, "only creator contract is allowed");
        _;
    }
    
    function mintNFT(
        address creator,
        address to,
        uint256 amount,
        string memory uri
    ) OnlyCreatorContract public virtual {
        _mintNFT(creator, to, tokenCount, uri, amount, "");
        tokenCount ++;
    }

    function burnNFT(uint256 id, uint256 amount) public virtual {
        _burn(_msgSender(), id, amount);
    }
    
}