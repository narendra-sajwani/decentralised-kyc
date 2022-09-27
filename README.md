# Decentralised Know Your Customer System
#### 1. This repo contains smart contract implementation in solidity to execute various functions as part of KYC system in a decentralised manner.
#### 2. The smart contract flow will be as follows:
* A bank collects details of the prospective customer off-chain and registers a KYC request onto the blockchain network by providing the username (unique for each customer) and hash of the link for the customer data stored in a secure storage.
* The bank then verifies the customer data and add that to the verified customer list stored on the network.
* Any bank can view any customer stored on the network by providing the username.
* Banks have the option to upvote/ downvote a customer.
* For the kyc status to remain true for a customer, the upvotes must be greater than the downvotes and the downvotes should not be more than one third of total number of banks registered on the network.
* The banks can register complaint against another bank if they find the bank to be curropt or if it is verifying false customers.
* If the number of complaints against a bank are more than one third of the total number of banks, then the bank is banned from executing bank functionalities such as adding KYC request, approving customer, upvote or downvote.
#### 3. Running the project on remix ide:
* The kyc-remix directory contains two solidity files namely BankInterface.sol (contains BankApp contract) and KYC.sol (contains the AdminApp contract, which is inheriting from the BankApp contract after importing the BankInterface.sol inside KYC.sol).
* Copy these two .sol files in the remix ide and compile them.
* Deploy AdminApp contract from any of the account provided in remix. This account will be assigned as admin at the time of deployment.
* Then, all the functions will be available in a nice GUI on left hand side, which can be called by passing in the required arguments.
* For testing, call addBank() from the admin account by passing in the required arguments to add a bank to the database. The address for bank can be chosen from any one of the account addresses (except admin address) provided in remix IDE.
* Add 5 or more banks by calling addBank() function from admin account.
* Then, choose any one bank and select corresponding account from the drop down and call addRequest() function to add a new KYC request in the requests mapping.
* Then, from the same bank address who has added the KYC request for the customer, call addCustomer() function to add this customer to customers mapping. 
(Assumption- The bank has verified the KYC data off-chain and is now adding it to the customers database (mapping) by passing in the required arguments and setting kycStatus as true and upvotes initialized by 1).
* After this, viewCustomer() may be called to see if the customer has been added correctly.
* You may try out other functions in the same manner as per contract flow.
