//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "./BankInterface.sol";

contract AdminApp is BankApp{
    address public admin;   //address of administrator of the network of banks

    //initialize admin  at the time of contract deployment
    constructor() {
        admin = msg.sender;
    }

    //only admin can call certain fucntions
    modifier onlyAdmin(address caller){
        require(caller == admin, "You are not authorized to perform this function");
        _;
    }

    //to add new bank to the list of banks by admin
    function addBank(string memory _name, address _ethAddress, string memory _regNumber) public onlyAdmin(msg.sender) returns(bool success){
        require(banks[_ethAddress].ethAddress == address(0), "Bank already exists");
        //add a bank to banks mapping only if it was not added already
        banks[_ethAddress].name = _name;
        banks[_ethAddress].ethAddress = _ethAddress;
        banks[_ethAddress].complaintsReported = 0;
        banks[_ethAddress].KYC_count = 0;
        banks[_ethAddress].isAllowedToVote = true;
        banks[_ethAddress].regNumber = _regNumber;
        numOfBanks++;
        success = true;
    }
    //to modify isAllowedToVote property for a bank by admin
    function modifyBankIsAllowedToVote(address _ethAddress, bool _isAllowedToVote) public onlyAdmin(msg.sender) returns(bool success){
        require(banks[_ethAddress].ethAddress != address(0), "No such bank exists");
        //change isAllowedToVote property for a bank only if the bank exists
        banks[_ethAddress].isAllowedToVote = _isAllowedToVote;
        success = true;
    }
    //to remove a bank from banks mapping by admin
    function removeBank(address _ethAddress) public onlyAdmin(msg.sender) returns(bool success){
        require(banks[_ethAddress].ethAddress != address(0), "No such bank exists");
        //remove the bank only if it exists
        delete banks[_ethAddress];
        success = true;
    }
}