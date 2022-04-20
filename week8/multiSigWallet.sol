// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract MultiSigWallet {
    // events
    event Deposit(address from, uint256 amount);
    event Submit(uint256 txn_id);
    event Approve(uint256 txn_id, address owner);
    event Revoke(uint256 txn_id, address owner);
    event Execute(uint256 txn_id);

    // structure for our submitted transactions
    struct Transaction {
        uint256 value;
        address to;
        bytes data;
        bool executed;
    }

    address[] public owners; // to store our multisig wallet owners, values assinged in contructor
    mapping(address => bool) public isOwner; // to store our owners addresses with value true confirming msg.sender is an owner
    uint256 public required; // the minimum number of approval required to execute a transaction

    Transaction[] public transactions; // array of type struct to store our transactions
    mapping(uint256 => mapping(address => bool)) public approved;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    modifier txnExists(uint _txn_id) {
        require(_txn_id < transactions.length, "transaction does not exsist");
        _;
    }

    modifier notApproved(uint _txn_id) {
        require(!approved[_txn_id][msg.sender], "transaction already approved");
        _;
    }

    modifier notExecuted(uint _txn_id) {
        require(!transactions[_txn_id].executed, "transaction already executed");
        _;
    }

    constructor(address[] memory _owners, uint256 _required) {
        require(
            _owners.length > 0,
            "There are no owners provided, owners required"
        );
        require(
            _required > 0 && _required <= _owners.length,
            "invalid required"
        );

        for (uint256 index = 0; index < _owners.length; index++) {
            address owner = _owners[index];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);

            required = _required;
        }
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submit(
        uint256 _value,
        address _to,
        bytes calldata _data
    ) external onlyOwner {
        transactions.push(
            Transaction({value: _value, to: _to, data: _data, executed: false})
        );

        emit Submit(transactions.length - 1);
    }

    function approve(uint256 _txn_id)
        external
        onlyOwner
        txnExists(_txn_id)
        notApproved(_txn_id)
        notExecuted(_txn_id)
        
    {
        approved[_txn_id][msg.sender] = true;
        emit Approve(_txn_id, msg.sender);
    }

    function _getApprovalCount(uint _txn_id) private view returns(uint count){
        for (uint256 index = 0; index < owners.length; index++) {
            if(approved[_txn_id][owners[index]]){
                count += 1;
            }
        }
    }

    function execute(uint _txn_id) external txnExists(_txn_id) notExecuted(_txn_id) {
        require(_getApprovalCount(_txn_id) >= required, "Not enough approvals") ;

        Transaction storage transaction = transactions[_txn_id];
        transaction.executed = true;

        (bool success, ) = transaction.to.call{
            value : transaction.value
        }(transaction.data);

        require(success, "transaction failed");
        emit Execute(_txn_id);
        
    }

    function revoke(uint _txn_id) external onlyOwner txnExists(_txn_id) notExecuted(_txn_id)  {
        require(approved[_txn_id][msg.sender], "You did not approve this transaction");
        approved[_txn_id][msg.sender] = false;
        emit Revoke(_txn_id, msg.sender);
    }
}

// remember to pass in the _owners array and the required while deploying the contract
// [
// "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
// "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
// "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"
// ],2