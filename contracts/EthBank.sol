pragma solidity >=0.4.22 <0.8.0;
import "../utils/SafeMath.sol";

contract Bank {
    using SafeMath for uint256;
    mapping (address => uint) private balances;
    uint256 private total;
    address public owner;
    event LogDepositMade(address accountAddress, uint amount);

    constructor () public {
        owner = msg.sender;
    }

    function deposit(address sender) public payable returns (uint) {
        // require((balances[msg.sender] + msg.value) >= balances[msg.sender]);

        // balances[msg.sender] += msg.value;

        // emit LogDepositMade(msg.sender, msg.value); // emit an event

        // return balances[msg.sender];
        require((total + msg.value) >= total);

        total = total.add(msg.value);

        emit LogDepositMade(sender, msg.value); // emit an event

        return total;
    }

    function withdraw(uint withdrawAmount, address payable account) public returns (uint remainingBal) {
        // require(withdrawAmount <= balances[msg.sender]);

        // balances[msg.sender] -= withdrawAmount;

        // msg.sender.transfer(withdrawAmount);

        // return balances[msg.sender];
        require(withdrawAmount <= total, "Insufficient ETH in Bank");

        total = total.sub(withdrawAmount);

        account.transfer(withdrawAmount);

        return total;
    }

    function balance() view public returns (uint) {
        // return balances[msg.sender];
        return total;
    }
}