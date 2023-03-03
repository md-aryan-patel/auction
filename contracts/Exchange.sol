// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Exchange is Ownable {
    enum Status {
        UNLISTED,
        LISTED,
        SOLD
    }

    mapping(uint256 => mapping(address => uint256)) Bids;

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

    mapping(uint256 => tokenSale) public sale;

    function createSale(
        address _token,
        uint256 _tokenId,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _baseValue
    ) public returns (bool) {
        ERC721 token_ = ERC721(_token);
        require(sale[_tokenId].tokenId == 0, "Exchange: Sale already exist");
        require(
            _endTime > _startTime && _startTime >= block.timestamp,
            "Exchange: End time should greater then start time"
        );
        require(
            token_.ownerOf(_tokenId) == msg.sender,
            "Exchange: Not your token"
        );
        sale[_tokenId] = tokenSale(
            msg.sender,
            token_,
            _tokenId,
            _startTime,
            _endTime,
            _baseValue,
            0,
            address(0),
            Status.LISTED
        );
        sale[_tokenId].toke.transferFrom(msg.sender, address(this), _tokenId);
        return true;
    }

    function _checkStatus(uint256 current) internal returns (Status) {
        if (
            block.timestamp >= sale[current].startTime &&
            block.timestamp <= sale[current].endTime
        ) return sale[current].status = Status.LISTED;
        else return sale[current].status = Status.UNLISTED;
    }

    function placeBid(uint256 _tokenId) public payable returns (uint256) {
        require(
            _checkStatus(_tokenId) == Status.LISTED,
            "Exchange: NFT Unlisted"
        );
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
        return msg.value;
    }

    function checkResult(uint256 _tokenId) public returns (address winner) {
        require(
            _checkStatus(_tokenId) == Status.UNLISTED,
            "Exchange: NFT Listed"
        );
        require(
            block.timestamp > sale[_tokenId].endTime,
            "Exchange: Can't declare result"
        );
        winner = sale[_tokenId].topBidder;
        if (winner == address(0)) {
            sale[_tokenId].toke.transferFrom(
                address(this),
                sale[_tokenId].owner,
                _tokenId
            );
            delete sale[_tokenId];
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
}
