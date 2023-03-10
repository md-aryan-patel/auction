// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./NFT.sol";

contract Tokens is ERC721, nft {

    string[] public _colors;
    uint256 _id;
    mapping(string => bool) _colorExist;

    constructor() ERC721("NFTtokens", "NFTOK") {}

    function mint(string memory _color) public returns(NFT memory){
        require(_colorExist[_color] == false);
        _id++;
        _colors.push(_color);
        _mint(tx.origin, _id);
        _colorExist[_color] = true;
        return NFT(_id, _color, msg.sender);
    }
}