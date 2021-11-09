// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.4;

import "./ERC1155.sol";

contract AnyMoeNFT is ERC1155 {
    
    uint256 private tokenCount = 0x0;

    constructor() public ERC1155() { }
    
    function mintNFT(
        address to,
        uint256 amount,
        string memory uri
    ) public virtual {
        _mintNFT(to, tokenCount, uri, amount, "");
        tokenCount ++;
    }
    
}