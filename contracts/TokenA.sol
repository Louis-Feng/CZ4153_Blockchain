pragma solidity >=0.4.22 <0.8.0;
import "../utils/SafeMath.sol";
import "./IERC20.sol";

//ERC Token Standard #20 Interface
contract TokenA is IERC20 {
    using SafeMath for uint256;
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    string public constant name = "Token A";
    string public constant symbol = "TA";
    uint8 public constant decimals = 18;

    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_;

    constructor(address owner) public {
        
        totalSupply_ = 1000000000000000000000000;
        balances[msg.sender] = totalSupply_; // Give the issuer all initial tokens
        // totalSupply_ = total;
        // balances[owner] = totalSupply_;
        emit Transfer(address(0), owner, totalSupply_);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }

    // function getNumToken(address tokenOwner) public view returns (uint256) {
    //     uint256 numTokens = balances[tokenOwner].div(10 ** uint256(this.decimals()));
    //     return numTokens;
    // }

    function transfer(address receiver, uint value) public returns (bool) {
        // uint256 value = numTokens.mul(10 ** uint256(this.decimals()));
        require(receiver != address(0));
        require(value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[msg.sender] = balances[msg.sender].add(value);
        //        balances[msg.sender] -= value;
        //        balances[receiver] += value;
        emit Transfer(msg.sender, receiver, value);
        return true;
    }

    function approve(address _spender, uint value) public returns (bool) {
        // uint256 value = numTokens.mul(10 ** uint256(this.decimals()));
        require(
                allowed[msg.sender][_spender].add(value) <= balances[msg.sender],
                "Approve amount is greater than balance."
            );
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(value);
        emit Approval(msg.sender,_spender, value);
        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint value) public returns (bool) {
        // uint256 value = numTokens.mul(10 ** uint256(this.decimals()));
        require(value <= balances[owner]);
        require(value <= allowed[owner][msg.sender]);


        balances[owner] = balances[owner].sub(value);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(value);
        balances[buyer] = balances[buyer].add(value);
        emit Transfer(owner, buyer, value);
        return true;
    }

}

