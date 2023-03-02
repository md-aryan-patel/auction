// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Exchange is Ownable {
    mapping(address => uint256) Bids;
    address[] bidders;

    constructor() {
        bidders.push(address(0));
        Bids[bidders[0]] = 0;
    }

    enum Status {
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
        Status status;
    }

    tokenSale sale;

    function createSale(
        address _token,
        uint256 _tokenId,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _baseValue
    ) public returns (bool) {
        ERC721 token_ = ERC721(_token);
        // require(_startTime >= block.timestamp && _endTime > _startTime, "Exchange: Time stamp inappropriate");
        require(
            token_.ownerOf(_tokenId) == msg.sender,
            "Exchange: Not yout token"
        );
        sale = tokenSale(
            msg.sender,
            token_,
            _tokenId,
            _startTime,
            _endTime,
            _baseValue,
            Status.LISTED
        );
        return true;
    }

    function _checkStatus() internal returns (Status) {
        if (
            block.timestamp >= sale.startTime && block.timestamp <= sale.endTime
        ) return sale.status = Status.LISTED;
        else return sale.status = Status.UNLISTED;
    }

    function placeBid() public payable returns (uint256) {
        uint256 lastIndex = _getBiddersLastIndex();
        // require(_checkStatus() == Status.LISTED);
        require(sale.owner != msg.sender);
        require(
            msg.value >= sale.baseValue,
            "Exchange: sent value less then base value"
        );
        require(
            msg.value >= Bids[bidders[lastIndex]],
            "Exchange: sent value is less then last bid"
        );
        bidders.push(msg.sender);
        Bids[bidders[_getBiddersLastIndex()]] = msg.value;
        return _getBiddersLastIndex();
    }

    function declareResult() public onlyOwner returns (address winner) {
        // require(_checkStatus() == Status.UNLISTED);
        winner = bidders[_getBiddersLastIndex()];
        payable(sale.owner).transfer(Bids[winner]);
        sale.toke.transferFrom(sale.owner, winner, sale.tokenId);
        delete Bids[winner];
        delete bidders[_getBiddersLastIndex()];
        for (uint256 i = _getBiddersLastIndex(); i > 0; i--) {
            payable(bidders[i]).transfer(
                (Bids[bidders[i]]) - (Bids[bidders[i]] / 100)
            );
            delete Bids[bidders[i]];
            delete bidders[i];
        }
        return winner;
    }

    function _getBiddersLastIndex() internal view returns (uint256) {
        uint256 lastIndex = bidders.length - 1;
        return lastIndex;
    }
}
