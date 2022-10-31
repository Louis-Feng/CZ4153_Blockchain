pragma solidity >=0.4.22 <0.8.0;
import "../utils/SafeMath.sol";
import "./IERC20.sol";

//ERC Token Standard #20 Interface
contract TokenB is IERC20 {
    using SafeMath for uint256;
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    string public constant name = "Token B";
    string public constant symbol = "TB";
    uint8 public constant decimals = 2;

    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_;

    constructor(uint256 total, address owner) public {
        totalSupply_ = total;
        balances[owner] = totalSupply_;
        emit Transfer(address(0), owner, total);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }

    function getNumToken(address tokenOwner) public view returns (uint256) {
        uint256 numTokens = balances[tokenOwner].div(10 ** uint256(this.decimals()));
        return numTokens;
    }

    function transfer(address receiver, uint numTokens) public returns (bool) {
        uint256 value = numTokens.mul(10 ** uint256(this.decimals()));
        require(receiver != address(0));
        require(value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[msg.sender] = balances[msg.sender].add(value);
        //        balances[msg.sender] -= value;
        //        balances[receiver] += value;
        emit Transfer(msg.sender, receiver, value);
        return true;
    }

    function approve(address _spender, uint numTokens) public returns (bool) {
        uint256 value = numTokens.mul(10 ** uint256(this.decimals()));
        allowed[_spender][msg.sender] = value;
        emit Approval(_spender ,msg.sender, value);
        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint numTokens) public returns (bool) {
        uint256 value = numTokens.mul(10 ** uint256(this.decimals()));
        require(value <= balances[owner]);
        require(value <= allowed[owner][msg.sender]);


        balances[owner] = balances[owner].sub(value);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(value);
        balances[buyer] = balances[buyer].add(value);
        emit Transfer(owner, buyer, value);
        return true;
    }

}

