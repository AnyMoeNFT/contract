pragma solidity ^0.8.4;

import "./AnyMoeAuctionInterface.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract AnyMoeAuction is Context, ERC165, IERC1155Receiver, AnyMoeNFTAuctionInterface {
    using Address for address;

    address payable private _owner;

    address private _nft_contract_address;
    IERC1155 private _nft_contract;

    uint256 private _increment_auction_id = 0x0;

    mapping(address => mapping(uint256 => uint256)) private _nft_balances;

    struct Auction {
        address owner;
        uint256 tokenId;
        uint256 amount;
        uint baseBid;
        uint bidIncrement;
        uint duration;
        uint startTime;
        bool settled;
        bool withdrawed;

        uint heighestBid;
        address heighestBidder;
        mapping(address => uint) bids;
        uint bidderCount;
    }

    mapping(uint256 => Auction) private _auctions;

    uint private _fee;

    uint private _fee_percentage;

    constructor(address nft_address, uint fee_percentage) {
        _owner = payable(_msgSender());
        _nft_contract_address = nft_address;
        _nft_contract = IERC1155(nft_address);
        _fee_percentage = fee_percentage;
    }

    function adminChangeFee(uint fee_percentage) public virtual {
        require(_msgSender() == _owner, "only anymoe team is allowed");
        _fee_percentage = fee_percentage;
    }

    function adminWithdrawFee() public virtual {
        require(_msgSender() == _owner, "only anymoe team is allowed");
        _owner.transfer(_fee);
        _fee = 0;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId;
    }

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external virtual override returns(bytes4) {
        require(_msgSender() == _nft_contract_address, "nft must be from specified contract");
        _nft_balances[_from][_id] += _value;
        emit TransferIn(_from, _id, _value);
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external virtual override returns(bytes4) {
        require(_msgSender() == _nft_contract_address, "nft must be from specified contract");
        require(_ids.length == _values.length, "ids and amounts length mismatch");
        for (uint256 i = 0; i < _ids.length; ++i) {
            _nft_balances[_from][_ids[i]] += _values[i];
            emit TransferIn(_from, _ids[i], _values[i]);
        }
        return this.onERC1155BatchReceived.selector;
    }

    function withdrawToken(uint256 id, uint256 amount) public virtual override {
        address owner = _msgSender();
        require(_nft_balances[owner][id] >= amount, "no enough nfts");
        _nft_balances[owner][id] -= amount;
        _nft_contract.safeTransferFrom(address(this), owner, id, amount, "");
        emit TransferOut(owner, id, amount);
    }

    function createAuction(uint256 tokenId, uint256 amount, uint baseBid, uint bidIncrement, uint duration) public virtual override returns (uint256) {
        address owner = _msgSender();
        require(_nft_balances[owner][tokenId] >= amount, "no enough nfts");
        uint256 auctionId = _increment_auction_id++;
        _nft_balances[owner][tokenId] -= amount;

        require(baseBid <= 2 ether, "baseBid is too heigh");
        require(bidIncrement <= 0.8 ether, "bidIncrement is too heigh");
        require(duration <= 2 weeks, "duration is too long");
        require(duration >= 12 hours, "duration is too short");
        _auctions[auctionId].owner = owner;
        _auctions[auctionId].tokenId = tokenId;
        _auctions[auctionId].amount = amount;
        _auctions[auctionId].baseBid = baseBid;
        _auctions[auctionId].bidIncrement = bidIncrement;
        _auctions[auctionId].duration = duration;

        emit CreateAuction(auctionId, owner, tokenId, amount, baseBid, bidIncrement, duration);
        return auctionId;
    }

    function placeBid(uint256 auctionId) public payable virtual override {
        require(_auctions[auctionId].owner != address(0), "no such auction");
        address bidder = _msgSender();
        if (_auctions[auctionId].startTime == 0) { // haven't start
            require(msg.value >= _auctions[auctionId].baseBid, "no enough money");
            _auctions[auctionId].startTime = block.timestamp;
            _auctions[auctionId].heighestBid = msg.value;
            _auctions[auctionId].heighestBidder = bidder;
            _auctions[auctionId].bids[bidder] = msg.value;
        } else {
            uint stopTime = _auctions[auctionId].startTime + _auctions[auctionId].duration;
            require(stopTime > block.timestamp, "auction already ended");
            _auctions[auctionId].bids[bidder] += msg.value;
            require(_auctions[auctionId].bids[bidder] >= _auctions[auctionId].heighestBid + _auctions[auctionId].bidIncrement, "no enough money");
            _auctions[auctionId].heighestBid = _auctions[auctionId].bids[bidder];
            _auctions[auctionId].heighestBidder = bidder;
            if (stopTime - block.timestamp <= 15 minutes) {
                _auctions[auctionId].duration += 15 minutes;
                emit DelayAuction(auctionId);
            }
        }
        _auctions[auctionId].bidderCount += 1;
        emit PlaceBid(auctionId, bidder, _auctions[auctionId].heighestBid);
    }

    function withdrawBid(uint256 auctionId) public virtual override {
        require(_auctions[auctionId].owner != address(0), "no such auction");
        address payable bidder = payable(_msgSender());
        require(bidder != _auctions[auctionId].heighestBidder, "heighest bidder can not withdraw");
        uint amount = _auctions[auctionId].bids[bidder];
        require(amount > 0, "you poor");
        _auctions[auctionId].bids[bidder] = 0;
        _auctions[auctionId].bidderCount -= 1;
        if (!bidder.send(amount)) {
            _auctions[auctionId].bids[bidder] = amount;
            _auctions[auctionId].bidderCount += 1;
        } else {
            emit WithdrawBid(auctionId, bidder);
        }
    }

    function settleAuction(uint256 auctionId) public payable virtual override {
        address payable sender = payable(_msgSender());
        require(_auctions[auctionId].owner != address(0), "no such auction");
        require(_auctions[auctionId].startTime != 0, "not start");
        require(_auctions[auctionId].settled == false, "already settled");
        require(_auctions[auctionId].startTime + _auctions[auctionId].duration < block.timestamp, "auction continue");
        require(sender == _auctions[auctionId].heighestBidder, "must heighest bidder");
        uint fee = _auctions[auctionId].heighestBid * _fee_percentage / 100;
        require(msg.value >= fee, "must pay enough fee");
        _auctions[auctionId].settled = true;
        _nft_balances[sender][_auctions[auctionId].tokenId] = _auctions[auctionId].amount;
        if (msg.value > fee) {
            sender.transfer(msg.value - fee);
        }
        _fee += fee;
        emit SettleAuction(auctionId, sender, _auctions[auctionId].amount);
    }

    function withdrawAuction(uint256 auctionId) public virtual override {
        address payable owner = payable(_msgSender());
        require(owner == _auctions[auctionId].owner, "must be owner");
        require(_auctions[auctionId].startTime != 0, "not start");
        require(_auctions[auctionId].withdrawed == false, "already withdrawed");
        require(_auctions[auctionId].startTime + _auctions[auctionId].duration < block.timestamp, "auction continue");
        _auctions[auctionId].withdrawed = true;
        uint fee = _auctions[auctionId].heighestBid * _fee_percentage / 100;
        uint withdraw = _auctions[auctionId].heighestBid - fee;
        if (!owner.send(withdraw)) {
            _auctions[auctionId].withdrawed = false;
        }
        _fee += fee;
        emit WithdrawAuction(auctionId, owner, withdraw);
    }

    function cancelAuction(uint256 auctionId) public virtual override {
        require(_auctions[auctionId].owner == _msgSender(), "only owner can cancel");
        require(_auctions[auctionId].startTime == 0, "started auction can not be canceled");
        _nft_balances[_msgSender()][_auctions[auctionId].tokenId] += _auctions[auctionId].amount;
        delete _auctions[auctionId];
        emit CancelAuction(auctionId);
    }
}