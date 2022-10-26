pragma solidity >=0.4.22 <0.8.0;
import "../utils/SafeMath.sol";

//ERC Token Standard #20 Interface
contract BasicToken {
    using SafeMath for uint256;
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    string public constant name = "ND Coin";
    string public constant symbol = "NDN";
    uint8 public constant decimals = 3;

    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_;

    constructor(uint256 total, address _owner) public {
        totalSupply_ = total;
        balances[_owner] = totalSupply_;
        emit Transfer(address(0), _owner, total);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint numTokens) public returns (bool) {
        require(receiver != address(0));
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[msg.sender] = balances[msg.sender].add(numTokens);
        //        balances[msg.sender] -= numTokens;
        //        balances[receiver] += numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address _spender, uint numTokens) public returns (bool) {
        allowed[msg.sender][_spender] = numTokens;
        emit Approval(msg.sender, _spender, numTokens);
        return true;
    }

    function reduceAllowance(
        address _owner,
        address _spender,
        uint256 _value
    ) public returns (uint256 currentAllowance) {
        allowed[_owner][_spender] = allowed[_owner][_spender].sub(_value);
        emit Approval(_owner, _spender, _value);
        return allowed[_owner][_spender];
    }


    function allowance(address _owner, address _spender) public view returns (uint) {
        return allowed[_owner][_spender];
    }

    function transferFrom(address _owner, address buyer, uint numTokens) public returns (bool) {
        require(numTokens <= balances[_owner]);
        require(numTokens <= allowed[_owner][msg.sender]);


        balances[_owner] = balances[_owner].sub(numTokens);
        allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(_owner, buyer, numTokens);
        return true;
    }
}