// SPDX-License-Identifier: GPl-3.0

pragma solidity 0.8.19;

contract MultiSignWallet{
    address[] public Owner;
    uint public NCR;

    struct Transaction{
        address to;
        uint value;
        bool status;
    }

    Transaction[] public Transactions;
    mapping(uint=>mapping(address=>bool)) isConfirmend;

    constructor(address[] memory o) {
        require(o.length>0,"More than 0 Owner is Requried");
        uint confirmationRequired = o.length;
        for(uint i = 0;i<o.length;i++){
            Owner.push(o[i]);
        }
        NCR = confirmationRequired;
        }

    function submitTransaction(address t) public payable{
        require(t!=address(0),"Valid Address Required");
        require(msg.value>0,"Valid Amount Required");
        Transactions.push(Transaction({to:t,value:msg.value,status:false}));
    }

    function confirmTransaction(uint tId) public{
        bool isOwner;
        for(uint i = 0;i<Owner.length;i++){
            if(msg.sender==Owner[i]){
                isOwner = true;
                break;
            }
        }

        require(isOwner,"Only Owner can confirm this transaction");
        require(tId<Transactions.length,"Valid Transaction Id Required");
        require(!isConfirmend[tId][msg.sender],"You Already Confirm This Transaction");
        isConfirmend[tId][msg.sender]= true;
        if(isTransactionConfiremd(tId)){
            executeTransaction(tId);
        }
    }

    function isTransactionConfiremd(uint tId) internal view returns(bool){
        require(tId<Transactions.length,"Valid Transaction Id Required");
        uint confirmCount;

        for(uint i = 0;i<Owner.length;i++){
                if(isConfirmend[tId][Owner[i]]){
                    confirmCount++;
                }
        }

        return confirmCount==NCR;
    }

    function executeTransaction(uint tId) public payable{
        require(tId<Transactions.length,"Valid Transaction Id Required");
        require(!(Transactions[tId].status),"Transaction is already executed");

        (bool success,) = Transactions[tId].to.call{value:Transactions[tId].value}("");
        require(success,"Transaction execution failed");
        Transactions[tId].status = true;
    }
}