// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract AnyMoeCreator is Context {
    using Address for address;

    address payable private _owner;

    constructor(address nft_address, uint fee_percentage) {
        _owner = payable(_msgSender());
    }
}