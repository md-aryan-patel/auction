// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Exchange is Ownable {
    enum Status {
        UNMARKED,
        UNLISTED,
        LISTED
    }

    struct tokenSale {
        address owner;
        ERC721 toke;
        uint256 tokenId;
        uint256 startTime;
        uint256 endTime;
        uint256 baseValue;
        uint256 topBid;
        address topBidder;
        Status status;
    }

    mapping(uint256 => tokenSale) sale;
    mapping(uint256 => mapping(address => uint256)) Bids;
    mapping(uint256 => bool) saleExist;

    event CreateSale(
        address owner,
        uint256 tokenId,
        uint256 startTime,
        uint256 endTime,
        Status status
    );

    event PlaceBid(address bidder, uint256 bid);

    function createSale(
        address _token,
        uint256 _tokenId,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _baseValue
    ) public returns (bool) {
        ERC721 token_ = ERC721(_token);
        // require(
        //     _endTime > _startTime && _startTime >= block.timestamp,
        //     "Exchange: End time should greater then start time"
        // );
        require(
            token_.ownerOf(_tokenId) == msg.sender,
            "Exchange: Not your token"
        );
        require(!saleExist[_tokenId], "Exchange: Sale already exist");
        sale[_tokenId] = tokenSale(
            msg.sender,
            token_,
            _tokenId,
            _startTime,
            _endTime,
            _baseValue,
            0,
            address(0),
            Status.UNMARKED
        );
        sale[_tokenId].toke.transferFrom(msg.sender, address(this), _tokenId);
        emit CreateSale(
            msg.sender,
            _tokenId,
            _startTime,
            _endTime,
            sale[_tokenId].status
        );
        return saleExist[_tokenId] = true;
    }

    function placeBid(uint256 _tokenId) public payable returns (uint256) {
        // require(
        //     _checkStatus(_tokenId) == Status.LISTED,
        //     "Exchange: NFT Unlisted"
        // );
        require(sale[_tokenId].owner != msg.sender, "Exchange Owner can't bid");
        require(
            msg.value >= sale[_tokenId].baseValue,
            "Exchange: sent value less then base value"
        );
        require(
            msg.value >= sale[_tokenId].topBid,
            "Exchange: sent value is less then last bid"
        );
        Bids[_tokenId][msg.sender] += msg.value;
        if (Bids[_tokenId][msg.sender] > sale[_tokenId].topBid) {
            sale[_tokenId].topBid = Bids[_tokenId][msg.sender];
            sale[_tokenId].topBidder = msg.sender;
        }
        emit PlaceBid(msg.sender, Bids[_tokenId][msg.sender]);
        return msg.value;
    }

    function cancelAuction(uint256 _tokenId) public returns (bool) {
        tokenSale memory currentSale = sale[_tokenId];
        require(msg.sender == currentSale.owner);
        // require(_checkStatus(_tokenId) == Status.UNMARKED);

        delete sale[_tokenId];
        delete saleExist[_tokenId];
        return true;
    }

    function checkResult(uint256 _tokenId) public returns (address winner) {
        require(
            _checkStatus(_tokenId) == Status.UNLISTED,
            "Exchange: NFT Listed"
        );
        winner = sale[_tokenId].topBidder;

        if (winner == address(0)) {
            sale[_tokenId].toke.transferFrom(
                address(this),
                sale[_tokenId].owner,
                _tokenId
            );
            delete sale[_tokenId];
            delete saleExist[_tokenId];
        } else if (msg.sender == winner) {
            payable(sale[_tokenId].owner).transfer(sale[_tokenId].topBid);
            sale[_tokenId].toke.transferFrom(
                address(this),
                winner,
                sale[_tokenId].tokenId
            );
            delete Bids[_tokenId][winner];
        } else {
            payable(msg.sender).transfer(
                (Bids[_tokenId][msg.sender]) -
                    (Bids[_tokenId][msg.sender]) /
                    100
            );
            delete Bids[_tokenId][msg.sender];
        }
    }

    function _checkStatus(uint256 current) internal returns (Status) {
        if (block.timestamp < sale[current].startTime)
            return sale[current].status = Status.UNMARKED;
        else if (
            block.timestamp >= sale[current].startTime &&
            block.timestamp <= sale[current].endTime
        ) return sale[current].status = Status.LISTED;
        else return sale[current].status = Status.UNLISTED;
    }

    function returnIfSaleExist(uint256 _tokenID) external view returns (bool) {
        return saleExist[_tokenID];
    }
}
