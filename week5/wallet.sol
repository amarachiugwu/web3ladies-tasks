// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Wallet{

    // receiver ether
    // send ether
    // store ether
    // withdraw ether
    // Get balance
    // Get balance in contract


    // Events
    event Deposit(address _addr, uint amount);
    event Send(address _addr, uint amount);
    event Withdraw(address _addr, uint amount);

    // Modifiers
    modifier hasEnough(address _addr, uint _amount){
        require(balances[_addr] >= _amount, "Insufficient funds");
        _;
    }

    // Mapping
    mapping(address => uint) public balances;

    // Receive Ether
    receive() external payable{
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Send Ether
    function send(address _receiver, uint _amount) external hasEnough(msg.sender, _amount){
        balances[_receiver] += _amount;
        balances[msg.sender] -= _amount;
        emit Send(_receiver, _amount);
    }

    // Withdraw Ether
    function withdraw(uint _amount) external hasEnough(msg.sender, _amount){
        balances[msg.sender] -= _amount;
        address payable _receiver = payable(msg.sender);
        (bool sent, ) = _receiver.call{ value:_amount }("");
        require(sent, "Ether not sent");
        emit Withdraw(msg.sender, _amount);
    }

    // Get balance
    function getBalance(address _addr) external view returns(uint){
        return balances[_addr];
    }

    // Get balance in contract 
    function getContractBalance() external view returns(uint){
        return address(this).balance;
    }
}