// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;


/** 
TASK

Build a wallet using Solidity where users would be able to store, send and receive ether.

Hint:
Use mappings to store user balances. 
**/

contract Wallet {

    struct WalletData {
        address addr;
        uint bal;
    }

    mapping (address => WalletData) walletList;
    address owner;

    constructor(){
        owner = msg.sender;
        uint balance = address(owner).balance;
        WalletData memory walletData = WalletData(owner, balance);
        walletList[owner] = walletData;
    }

    // transfer ether out of wallet
    function transfer (address payable _to) public payable {
        uint amount = 1 ether;
        // require(amount <= address(msg.sender).balance, "Insufficient Ether");
        bool sent = _to.send(amount);
        require(sent, "Failed to send Ether");
        uint balance = address(_to).balance + 1;
        WalletData memory walletData = WalletData(_to, balance);
        walletList[_to] = walletData;
    }

    // recieve ether into walllet
    function recieve () public  {
        uint balance = address(this).balance;
        balance += 1 ether;
    }


    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}


    // get ether balance
    function getBalance (address _address) public view returns(uint){
        // return walletList[_address].bal;
        return address(msg.sender).balance;
    }
}