pragma solidity >=0.4.22 <0.8.0;
import "../utils/SafeMath.sol";
import "./IERC20.sol";

//ERC Token Standard #20 Interface
contract BasicToken is IERC20 {
    using SafeMath for uint256;
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Removal(address indexed tokenOwner, address indexed spender, uint tokens);

    string public constant name = "ND Coin";
    string public constant symbol = "NDN";
    uint8 public constant decimals = 18;

    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_;

    constructor(address owner) public {
        
        totalSupply_ = 0;
        // balances[msg.sender] = totalSupply_; // Give the issuer all initial tokens
        // totalSupply_ = total;
        // balances[owner] = totalSupply_;
        // emit Transfer(address(0), owner, totalSupply_);
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
                allowed[_spender][msg.sender].add(value) <= balances[_spender],
                "Approve amount is greater than balance."
            );
        allowed[_spender][msg.sender] = allowed[_spender][msg.sender].add(value);
        emit Approval(_spender, msg.sender, value);
        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint) {
        return allowed[owner][delegate];
    }

    function reduceAllowance(
         address _owner,
         address _spender,
         uint256 _value
     ) public returns (uint256 currentAllowance) {
         allowed[_owner][_spender] = allowed[_owner][_spender].sub(_value);
         emit Removal(_owner, _spender, _value);
         return allowed[_owner][_spender];
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

    function mint(address account, uint value) public returns (bool) {
        totalSupply_ = totalSupply_.add(value);
        balances[account] = balances[account].add(value);
        emit Transfer(address(0), account, value);
        return true;
    }

    function burn(address account, uint value) public returns (bool) {
        require(balances[account]>= value, "insufficinet BasicToken");
        // sender.transfer(value);


        balances[account] = balances[account].sub(
            value,
            "ERC20: Burn value exceeds balance"
        );
        totalSupply_ = totalSupply_.sub(value);
        emit Transfer(account, address(0), value);
        return true;
    }

}

