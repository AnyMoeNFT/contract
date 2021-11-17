// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.4;

interface AnyMoeNFTAuctionInterface {
    event TransferIn(address owner, uint256 tokenId, uint256 amount);
    event TransferOut(address destination, uint256 tokenId, uint256 amount);
    event CreateAuction(uint256 auctionId, address owner, uint256 tokenId, uint256 amount, uint baseBid, uint bidIncrement, uint duration);
    event CancelAuction(uint256 auctionId);
    event PlaceBid(uint256 auctionId, address bidder, uint bidAmount);
    event WithdrawBid(uint256 auctionId, address bidder);
    event DelayAuction(uint256 auctionId);
    event SettleAuction(uint256 auctionId, address destination, uint256 amount);
    event WithdrawAuction(uint256 auctionId, address destination, uint amount);

    function withdrawToken(uint256 id, uint256 amount) external;
    function createAuction(uint256 tokenId, uint256 amount, uint baseBid, uint bidIncrement, uint duration) external returns (uint256);
    function placeBid(uint256 auctionId) payable external;
    function settleAuction(uint256 auctionId) payable external;
    function withdrawBid(uint256 auctionId) external;
    function withdrawAuction(uint256 auctionId) external;
    function cancelAuction(uint256 auctionId) external;

    function getAuction(uint256 auctionId) view external returns(address, uint256, uint256, uint, uint, uint, uint, bool, bool, uint, address, uint);
    function getFeeRate() view external returns(uint, uint);
}