//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

contract BankApp {
    struct Customer {
        string username;   //entered by customer
        string customerData;   //hash of the link for the customer data
        bool kycStatus; //status of KYC request of a customer
        uint upvotes;   //number of upvotes received from other banks over customer data
        uint downvotes;  //number of downvotes received from other banks over customer data
        address bank;   //unique address of the bank that validated the customer account
    }
    struct KYCRequest {
        string username;   //entered by customer
        string customerData;   //hash of the link for the customer data
        address bank;   //unique address of the bank that initiated a KYC request
    }
    struct Bank {
        string name;   //name of the bank/ organization
        address ethAddress;  //unique ethereum address of the bank/ organization
        uint complaintsReported; //number of complaints against this bank
        uint KYC_count;  //number of KYC requests initiated by the bank/ organization
        bool isAllowedToVote;   //if set to false, bank can not use functions for a bank
        string regNumber;  //unique registration number of the bank
    }
    uint public numOfBanks; //to keep track of total banks
    mapping(string => Customer) public customers;  //to maintain a list of customers (keys: username)
    mapping(string => KYCRequest) public requests; //to maintain a list of KYC requests (keys: username)
    mapping(address => Bank) public banks;  //to maintain a list of banks (keys: unique address for bank)
    
    //Only those banks are allowed to execute bank functionalities for which isAllowedToVote is true
    modifier onlyAllowedBank(address bank) {
        require(banks[bank].isAllowedToVote, "Bank is not allowed for executing this fucntion");
        _;
    }

    //to add new kyc request by a bank
    function addRequest(string memory _username, string memory _customerData) public onlyAllowedBank(msg.sender) returns (bool success){
        require(requests[_username].bank == address(0), "KYC request has already been added for this customer");
        require(customers[_username].bank == address(0), "Customer is already present in the database");
        //add to requests only if customer was not already added
        requests[_username].username = _username;
        requests[_username].customerData = _customerData;
        requests[_username].bank = msg.sender;
        success = true;
    }
    //to add customer to customers' list by a bank
    /*assumption - only the bank which has initiated the kyc request, 
    will verify it off-chain and then add customer the database i.e. in the customers mapping*/
    function addCustomer(string memory _username, string memory _customerData) public onlyAllowedBank(msg.sender) returns(bool success){
        //customer should not be present in the database already
        require(customers[_username].bank == address(0), "Customer is already present in the database");
        //customer must be present in the requests mapping, where all kyc requests are stored
        require(requests[_username].bank != address(0), "KYC request to be added first before adding the customer to database");
        /*assumption - only the bank which has initiated the kyc request, 
        will verify it off-chain and then add customer the database i.e. in the customers mapping*/
        require(requests[_username].bank == msg.sender, "Only the bank who initiated the KYC request can add this customer to the database");
        //add to customers mapping, if all above checks are passed and bank has verified the kyc data of customer off-chain
        customers[_username].username = _username;
        customers[_username].customerData = _customerData;
        customers[_username].bank = msg.sender;
        customers[_username].upvotes = 1;
        customers[_username].kycStatus = true;
        success = true;
    }
    //to remove a kyc request by a bank
    function removeRequest(string memory _username) public onlyAllowedBank(msg.sender) returns(bool success) {
        require(requests[_username].bank != address(0), "There is no such request to remove");
        //remove only if request exist in the requests mapping
        delete requests[_username];
        success = true;
    }
    //to view complete data of customer by a bank
    function viewCustomer(string memory _username) public view onlyAllowedBank(msg.sender)
    returns(string memory, string memory, bool, uint, uint, address) {
        require(customers[_username].bank != address(0), "Customer doesn't exist");
        //return customer's data only if customer exist
        return (customers[_username].username, customers[_username].customerData,
        customers[_username].kycStatus, customers[_username].upvotes, 
        customers[_username].downvotes, customers[_username].bank);
    }
    //to upvote a customer by a bank
    function upvote(string memory _username) public onlyAllowedBank(msg.sender) returns(bool success){
        require(customers[_username].bank != address(0), "Customer doesn't exist");
        //upvote by bank only if customer is present
        customers[_username].upvotes += 1;
        //also, check the total upvotes and downvotes and modify the kyc status accordingly
        //Here, we are assuming that there are at least 5 banks in the network
        if(customers[_username].upvotes > customers[_username].downvotes && customers[_username].downvotes < numOfBanks/3){
            customers[_username].kycStatus = true;
        }else{
            customers[_username].kycStatus = false;
        }
        success = true;
    }
    //to downvote a customer by a bank
    function downvote(string memory _username) public onlyAllowedBank(msg.sender) returns(bool success){
        require(customers[_username].bank != address(0), "Customer doesn't exist");
        //downvote by bank only if customer is present
        customers[_username].downvotes += 1;
        //also, check the total upvotes and downvotes and modify the kyc status accordingly
        //Here, we are assuming that there are at least 5 banks in the network
        if(customers[_username].upvotes > customers[_username].downvotes && customers[_username].downvotes < numOfBanks/3){
            customers[_username].kycStatus = true;
        }else{
            customers[_username].kycStatus = false;
        }
        success = true;
    }
    //to modify customer's data by a bank
    function modifyCustomer(string memory _username) public onlyAllowedBank(msg.sender) returns(bool success){
        /*this function need to perform two operations
        1. to remove the customer from requests list if it exists in requests list.
        2. to set the number of upvotes and downvotes to zero if customer exists in customers list
        */
        require(requests[_username].bank != address(0), "There is no such request to remove");
        delete requests[_username];
        require(customers[_username].bank != address(0), "Customer doesn't exist");
        customers[_username].upvotes = 0;
        customers[_username].downvotes = 0;
        success = true;
    }
    //to get the number of complaints against any bank (assuming that admin as well as any bank can call this function)
    function getBankComplaints(address _ethAddress) public view returns(uint){
        require(banks[_ethAddress].ethAddress != address(0), "No such bank exists");
        //get the number of complaint for a bank only if it exists
        return banks[_ethAddress].complaintsReported;
    }
    //to view the details of any bank (assuming that admin as well as any bank can call this function)
    function viewBankDetails(address _ethAddress) public view returns(Bank memory){
        require(banks[_ethAddress].ethAddress != address(0), "No such bank exists");
        //get the bank details only if it exists
        return banks[_ethAddress];
    }
    //to report a complaint against any bank by other banks
    function reportBank(address _ethAddress, string memory _name) public onlyAllowedBank(msg.sender) returns(bool success){
        require(banks[_ethAddress].ethAddress != address(0), "No such bank exists");
        /*If such bank exists, then this fucntion need to perform two things
        1. Increment the complaintsReported by 1
        2. Modify isAllowedToVote as per conditions mentioned in problem statement
        */
        banks[_ethAddress].complaintsReported += 1;
        if(banks[_ethAddress].complaintsReported > numOfBanks/3){
            banks[_ethAddress].isAllowedToVote = false;
        }
        success =  true;
    }
}