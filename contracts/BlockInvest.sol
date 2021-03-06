pragma solidity ^0.4.2; // should actually be 0.4.21

contract Invest {
    uint public value;
    // el inversor
    address public investor;
    // el gestor de la cuenta
    address public manager;
    enum State { PurchaseRequested, InProgress, PurchaseConfirmed, Cancelled }
    State public state;

    // Ensure that `msg.value` is an even number.
    // Division will truncate if it is an odd number.
    // Check via multiplication that it wasn't an odd number.
    function Invest() public payable {
        investor = msg.sender;
        value = msg.value / 2;
        require((2 * value) == msg.value);
    }

    modifier condition(bool _condition) {
        require(_condition);
        _;
    }

    modifier onlyBuyer() {
        require(msg.sender == investor);
        _;
    }

    modifier onlySeller() {
        require(msg.sender == manager);
        _;
    }

    modifier inState(State _state) {
        require(state == _state);
        _;
    }

  //  event Aborted();
  //  event InvestmentConfirmed();
  //  event ItemReceived();

    /// Abort the purchase and reclaim the ether.
    /// Can only be called by the seller before
    /// the contract is locked.
    function abort()
        public
        onlySeller
        inState(State.Cancelled)
    {
      //  emit Aborted();
        state = State.Cancelled;
        manager.transfer(this.balance);
    }

    /// Confirm the purchase as buyer.
    /// Transaction has to include `2 * value` ether.
    /// The ether will be locked until confirmReceived
    /// is called.
    function confirmInvestment()
        public
        inState(State.PurchaseConfirmed)
        condition(msg.value == (2 * value))
        payable
    {
      //  emit InvestmentConfirmed();
        investor = msg.sender;
        state = State.PurchaseConfirmed;
    }

    /// Confirm that you (the buyer) received the item.
    /// This will release the locked ether.
    function confirmReceived()
        public
        onlyBuyer
        inState(State.PurchaseConfirmed)
    {
      //  emit PurchaseConfirmed();
        // It is important to change the state first because
        // otherwise, the contracts called using `send` below
        // can call in again here.
        // state = State.Inactive;

        // NOTE: This actually allows both the buyer and the seller to
        // block the refund - the withdraw pattern should be used.

        investor.transfer(value);
        manager.transfer(this.balance);
    }
}
