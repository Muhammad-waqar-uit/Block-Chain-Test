// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
// Uncomment this line to use console.log
// import "hardhat/console.sol";

interface QTKN_ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transferToken(address to, uint256 value) external payable;
    event Transfer(address indexed from, address indexed to, uint256 value);
}

abstract contract QTKN is QTKN_ERC20{
    string public name='QTKN Token';
    string public symbol='QTKN';
    uint256 public _totalSupply;
    address public owner;
    //mapping for the balances
    mapping(address => uint256) public balances;

    constructor() {
        balances[msg.sender]=_totalSupply;
        owner=msg.sender;
    }
// Event for transfer Tokens
    function totalSupply() public view returns (uint256){
        return _totalSupply;
    }

    function transferToken(address _to) public payable{
        require(balances[msg.sender]>=100);
        require(msg.value>=1 ether); 
        balances[msg.sender] -=100;
        balances[_to]+=100;
        emit Transfer(msg.sender, _to, 100);
    }

    function balanceOf(address _account) public view returns(uint256){
        return balances[_account];
    }

    // function _mint(address to,uint256 value) public {
    //     require(balances[msg.sender]>=value);

    // }
}