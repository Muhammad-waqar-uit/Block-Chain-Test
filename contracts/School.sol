// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract School{
    string coursename;
    address teacher;
    address owner;
    uint256 baseterm;
    mapping (uint256=>coursename) courses;
    constructor(){
        owner=msg.sender;
        baseterm=90;
    }

    modifier onlyteacher() {
        require(msg.sender == teacher);
        _;
    }

}