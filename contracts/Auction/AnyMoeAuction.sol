pragma solidity ^0.8.4;

import "./AnyMoeAuctionInterface.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract AnyMoeAuction is Context, ERC165, IERC1155Receiver, AnyMoeNFTAuctionInterface {
    using Address for address;

    address private _nft_contract_address;

    uint256 private _increment_auction_id = 0x0;

    mapping(address => mapping(uint256 => uint256)) private _nft_balances;

    struct Auction {
        address owner;
        uint256 tokenId;
        uint256 amount;
        uint baseBid;
        uint bidIncrement;
        uint duration;
        uint startBlock;

        uint heighestBid;
        address heighestBidder;
        mapping(address => uint) bids;
    }

    mapping(uint256 => Auction) private _auctions;

    constructor(address nft_address) {
        _nft_contract_address = nft_address;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId;
    }

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external virtual override returns(bytes4) {
        require(_msgSender() == _nft_contract_address, "nft must be from specified contract");
        _nft_balances[_operator][_id] += _value;
        emit TransferIn(_operator, _id, _value);
    }

    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external virtual override returns(bytes4) {
        require(_msgSender() == _nft_contract_address, "nft must be from specified contract");
        require(_ids.length == _values.length, "ids and amounts length mismatch");
        for (uint256 i = 0; i < _ids.length; ++i) {
            _nft_balances[_operator][_ids[i]] += _values[i];
            emit TransferIn(_operator, _ids[i], _values[i]);
        }
    }

    function createAuction(uint256 tokenId, uint256 amount, uint baseBid, uint bidIncrement, uint duration) public virtual override {
        address owner = _msgSender();
        require(_nft_balances[owner][tokenId] >= amount, "no enough nfts");
        uint256 auctionId = _increment_auction_id++;
        _nft_balances[owner][tokenId] -= amount;
        
        _auctions[auctionId].owner = owner;
        _auctions[auctionId].tokenId = tokenId;
        _auctions[auctionId].amount = amount;
        _auctions[auctionId].baseBid = baseBid;
        _auctions[auctionId].bidIncrement = bidIncrement;
        _auctions[auctionId].duration = duration;

        emit CreateAuction(auctionId, owner, tokenId, amount, baseBid, bidIncrement, duration);
    }

    function placeBid(uint256 auctionId) public payable virtual override {
        require(_auctions[auctionId].owner != address(0), "no such auction");
        if (_auctions[auctionId].startBlock == 0) { // haven't start
            require(msg.value >= _auctions[auctionId].baseBid, "no enough money");
        }
        
    }
}