pragma solidity ^0.8.4;

interface AnyMoeNFTAuctionInterface {
    event TransferIn(address owner, uint256 tokenId, uint256 amount);
    event TransferOut(address destination, uint256 tokenId, uint256 amount);
    event CreateAuction(uint256 auctionId, address owner, uint256 tokenId, uint256 amount, uint baseBid, uint bidIncrement, uint duration);
    event CancelAuction(uint256 auctionId);
    event PlaceBid(uint256 auctionId, address bidder, uint bidAmount);
    event DelayAuction(uint256 auctionId);
    event SettleAuction(uint256 auctionId, address destination);

    function createAuction(uint256 tokenId, uint256 amount, uint baseBid, uint bidIncrement, uint duration) external;
    function placeBid(uint256 auctionId) payable external;
}