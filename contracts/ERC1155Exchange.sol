// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract ERC1155Exchange {
    mapping(uint256 => mapping(address => uint256)) Bids;
    mapping(uint256 => mapping(address => uint256)) tokenAmount;
    mapping(uint256 => mapping(address => bool)) isWinner;

    struct Sale {
        ERC1155 token;
        address owner;
        uint256 amount;
        uint256 buyPrice;
        uint256 minBid;
    }

    mapping(uint256 => Sale) public sale;

    event CreateAuction(
        address tokenAddress,
        address owner,
        uint256 amount,
        uint256 buyPrice,
        uint256 minBid
    );

    function createAuction(
        address _token,
        uint256 _amount,
        uint256 _id,
        uint256 _buyPrice,
        uint256 _minBid
    ) public returns (bool) {
        ERC1155 token = ERC1155(_token);
        require(address(sale[_id].token) == address(0), "Sale already exist");
        require(
            _amount <= token.balanceOf(msg.sender, _id),
            "User dont have enough to create auction"
        );
        sale[_id] = Sale(token, msg.sender, _amount, _buyPrice, _minBid);
        emit CreateAuction(_token, msg.sender, _amount, _buyPrice, _minBid);
        return true;
    }

    function instentBuy(uint256 _id) public payable {
        Sale memory currentSale = sale[_id];
        require(
            msg.value >= currentSale.buyPrice,
            "Exchange: Less price then listed"
        );
        payable(currentSale.owner).transfer(msg.value);
        currentSale.token.safeTransferFrom(
            currentSale.owner,
            msg.sender,
            _id,
            1,
            "token sent"
        );
    }

    function placeBid(
        uint256 _id,
        uint256 _amount
    ) public payable returns (uint256) {
        Sale memory currentSale = sale[_id];
        require(
            currentSale.token.balanceOf(currentSale.owner, _id) >= _amount,
            "Exchange: Amount exceed"
        );
        if (Bids[_id][msg.sender] < 0) {
            require(
                msg.value >= currentSale.minBid,
                "Exchange: First Bid should be greater then Mininum bid"
            );
            require(_amount > 0, "Exchange: Amount can't be zero");
        }
        require(msg.sender != currentSale.owner, "Exchange Owner can't bid");
        tokenAmount[_id][msg.sender] += _amount;
        return Bids[_id][msg.sender] += msg.value;
    }

    function pickWinners(
        uint256 _id,
        address[] memory winners
    ) public returns (uint256) {
        Sale memory currentSale = sale[_id];
        require(msg.sender == currentSale.owner, "Exchange: Not Owner");
        for (uint256 i = 0; i < winners.length; i++) {
            isWinner[_id][winners[i]] = true;
        }
        return winners.length;
    }

    function checkResult(uint256 _id) public returns (address transferTo) {
        Sale memory currentSale = sale[_id];
        if (isWinner[_id][msg.sender] == true) {
            currentSale.token.safeTransferFrom(
                currentSale.owner,
                msg.sender,
                _id,
                tokenAmount[_id][msg.sender],
                ""
            );
            transferTo = currentSale.owner;
            delete isWinner[_id][msg.sender];
        } else transferTo = msg.sender;

        payable(transferTo).transfer(
            Bids[_id][msg.sender] - Bids[_id][msg.sender] / 100
        );
        delete Bids[_id][msg.sender];
    }
}
