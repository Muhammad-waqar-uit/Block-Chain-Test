// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract UniqueToken {
    string public name;
    string public symbol;
    uint8 public decimals = 0;
    mapping(address => uint) public balanceOf;
    mapping(uint => address) public tokenIdOwner;
    event Transfer(address indexed from, address indexed to, uint tokenId);
    uint public totalSupply = 0;

    constructor() {
        name = "Unique Token";
        symbol = "UTK";
    }

    function mint(address _to) public {
        require(_to != address(0), "Invalid recipient address.");
        require(balanceOf[_to] == 0, "Recipient already owns a token.");
        totalSupply++;
        balanceOf[_to] = totalSupply;
        tokenIdOwner[totalSupply] = _to;
        emit Transfer(address(0), _to, totalSupply);
    }

    function transfer(address _to, uint _tokenId) public {
        require(tokenIdOwner[_tokenId] == msg.sender, "Sender is not the owner of the token.");
        require(tokenIdOwner[_tokenId] != address(0), "Token is not owned.");
        require(_to != address(0), "Invalid recipient address.");
        require(balanceOf[_to] == 0, "Recipient already owns a token.");
        tokenIdOwner[_tokenId] = _to;
        balanceOf[msg.sender] = 0;
        balanceOf[_to] = _tokenId;
        emit Transfer(msg.sender, _to, _tokenId);
    }
}
