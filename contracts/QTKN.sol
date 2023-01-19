// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
// Uncomment this line to use console.log
// import "hardhat/console.sol";

interface QTKN_ERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    function totalSupply() external view returns (uint256);
    
    function balanceOf(address account) external view returns (uint256);
    
    function transfer(address to, uint256 value) external payable;

}


interface IERMetaData is QTKN_ERC20{
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);
}

abstract contract context {
    function _msgSender() internal view virtual returns (address){
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract QTKN is QTKN_ERC20,context,IERMetaData{
    //mapping for the balances
    mapping(address => uint256) private balances;

    //mapping for allowance
    mapping(address => mapping(address => uint256)) private 
    _allowance;
    //coin name
    string public name='QTKN Token';
    //coin symbol
    string public symbol='QTKN';
    //coin supply
    uint256 private _totalSupply;
    //owner of the coin
    address public owner;


function checkBalance() public view returns (uint256) {
    return address(this).balance;
}

    constructor(uint256 total) {
        _totalSupply=total;
        balances[msg.sender]=_totalSupply;
        owner=msg.sender;
    }
// Event for transfer Tokens
    function totalSupply() public view returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address _account) public view returns    (uint256){
        return balances[_account];
    }

    function transfer(address _to) public payable{
        require(balances[msg.sender]>=100);
        require(msg.value>=1 ether); 
        balances[msg.sender] -=100;
        balances[_to]+=100;
        emit Transfer(msg.sender, _to, 100);
    }

    function mint(address to, uint256 value)  public {
        require(msg.sender==owner);
        balances[to]+=value;
        _totalSupply+=value;
        emit Transfer(address(0), to, value);
    }
}