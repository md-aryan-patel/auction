// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Exchange {
    mapping(address => uint256) Bids;
    mapping(address => bool) isWinner;

    struct Sale {
        ERC1155 token;
        address owner;
        uint256 amount;
        uint256 id;
        uint256 buyPrice;
        uint256 minBid;
    }

    Sale public sale;

    function createAuction(
        address _token,
        uint256 _amount,
        uint256 _id,
        uint256 _buyPrice,
        uint256 _minBid
    ) public returns (bool) {
        ERC1155 token = ERC1155(_token);
        require(
            _amount <= token.balanceOf(msg.sender, _id),
            "User dont have enough to create auction"
        );
        sale = Sale(token, msg.sender, _amount, _id, _buyPrice, _minBid);
        return true;
    }

    function InstentBuy() public payable {
        require(msg.value >= sale.buyPrice);
        payable(sale.owner).transfer(msg.value);
        sale.token.safeTransferFrom(sale.owner, msg.sender, sale.id, 1, "");
    }

    function placeBid() public payable returns (uint256) {
        require(msg.value >= sale.minBid);
        require(msg.sender != sale.owner, "Exchange Owner can't bid");
        return Bids[msg.sender] += msg.value;
    }

    function declareWinners(address[] memory winners) public returns (uint256) {
        require(msg.sender == sale.owner, "Exchange: Not Owner");
        for (uint256 i = 0; i < winners.length; i++) {
            isWinner[winners[i]] = true;
        }
        return winners.length;
    }

    function checkResult() public {
        address transferTo;
        if (isWinner[msg.sender] == true) {
            sale.token.safeTransferFrom(sale.owner, msg.sender, sale.id, 1, "");
            transferTo = sale.owner;
            delete isWinner[msg.sender];
        } else transferTo = msg.sender;

        payable(transferTo).transfer(Bids[msg.sender] - Bids[msg.sender] / 100);
        delete Bids[msg.sender];
    }
}
