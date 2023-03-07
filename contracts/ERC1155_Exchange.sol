// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Exchange {
    mapping(uint256 => mapping(address => uint256)) Bids;
    mapping(uint256 => mapping(address => bool)) isWinner;

    struct Sale {
        ERC1155 token;
        address owner;
        uint256 amount;
        uint256 buyPrice;
        uint256 minBid;
    }

    mapping(uint256 => Sale) public sale;

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
        return true;
    }

    function InstentBuy(uint256 _id) public payable {
        Sale memory currentSale = sale[_id];
        require(msg.value >= currentSale.buyPrice);
        payable(currentSale.owner).transfer(msg.value);
        currentSale.token.safeTransferFrom(
            currentSale.owner,
            msg.sender,
            _id,
            1,
            ""
        );
    }

    function placeBid(uint256 _id) public payable returns (uint256) {
        Sale memory currentSale = sale[_id];
        require(msg.value >= currentSale.minBid);
        require(msg.sender != currentSale.owner, "Exchange Owner can't bid");
        return Bids[_id][msg.sender] += msg.value;
    }

    function declareWinners(
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
                1,
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
