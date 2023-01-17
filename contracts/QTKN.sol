// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract QTKN is ERC20{
    uint256 public _totalSupply=100000;
    address public owner;
    mapping(address=>bool) registerdStudents;
    mapping(address => uint256) balances;
    modifier onlyOwner(){
        require(msg.sender==owner);
        _;
    }

    event transfer(address indexed from, address indexed to, uint256 value);
 
    constructor() ERC20("ERC20","QTKN"){
        balances[msg.sender]=_totalSupply;
        owner=msg.sender;
    }

    function totalSupply() public view override returns(uint256){
        return _totalSupply;
    }

    function BuyTokens(uint256 _value) public payable {
        require(msg.value >=1 ether,"NOT Enough Etheruem");
        require(_totalSupply >= 100);
        _mint(msg.sender,100);
        _totalSupply-100;
        emit Transfer(address(0), msg.sender, _value);
    }

    function balanceOf(address _account) public view override returns(uint256 balance){
        return balances[_account];
    }
    
    function registration(uint256 _value) public payable {
    require(msg.value>=100);
    require(registerdStudents[msg.sender],'You are Already Registered');
    registerdStudents[msg.sender]=true;        
    }
}