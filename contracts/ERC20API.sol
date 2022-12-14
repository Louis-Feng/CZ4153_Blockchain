pragma solidity >=0.4.22 <0.8.0;
import "./IERC20.sol";

contract ERC20API is IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);
    function reduceAllowance(
         address _owner,
         address _spender,
         uint256 _value
     ) external returns (uint256 currentAllowance);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
    event Removal(address indexed tokenOwner, address indexed spender, uint tokens);

}