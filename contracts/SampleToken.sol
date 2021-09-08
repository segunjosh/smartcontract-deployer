// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

// ----------------------------------------------------------------------------
// 
//
// Deployed to : msg.sender
// Symbol      : SAM
// Name        : SAMPLE TOKEN
// Total supply: 1,000,000,000
// Decimals    : 18

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
   constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    } 

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

interface SAMPLETOKENUX {
    function authenticate(address _sender, uint _value, uint _challenge, uint _partnerId) external;
}

interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external;
}

interface CRC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function OwnerAccountBalance(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   * Returns a boolean value indicating whether the operation succeeded.
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract SAMLETOKEN is Ownable, CRC20 {
   using SafeMath for uint256;

    string public _name;
    string public _symbol;
    uint8 public _decimals;  // Number of decimals of the smallest unit
    uint public _totalSupply;

    mapping (address => uint256) public balances;
    // `allowed` tracks any extra transfer rights as in all SAMPLE tokens
    mapping (address => mapping (address => uint256)) public allowed;

 constructor() public{
        _name='SAMPLE TOKEN';
        _symbol='SAMP';
        _decimals=18;
       _totalSupply = (1000000000 * 10**18);
        // Give the creator all initial tokens
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
  // Returns Token Symbol
  function symbol() public override view returns (string memory) {
    return _symbol;
  }
  
  // Returns Token Decimals
  function decimals() external view override returns (uint8) {
    return _decimals;
  }
  
 // Returns Token Name
  function name() public override view returns (string memory) {
    return _name;
  }

  // Returns Token totalSupply
   function totalSupply() public view override returns (uint) {
        return _totalSupply;
  }
    
   function transfer(address _to, uint256 _amount) public override  returns (bool success) {
        doTransfer(msg.sender, _to, _amount);
        return true;
  }

  function transferFrom(address _from, address _to, uint256 _amount
    ) public override returns (bool success) {
        // The standard ERC 20 transferFrom functionality
        require(allowed[_from][msg.sender] >= _amount);
        allowed[_from][msg.sender] -= _amount;
        doTransfer(_from, _to, _amount);
        return true;
    }
    
    function doTransfer(address _from, address _to, uint _amount
    ) internal {
        // Do not allow transfer to 0x0 or the token contract itself
        require((_to != address(0)) && (_to != address(this)));
        require(_amount <= balances[_from]);
        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
    }

  function OwnerAccountBalance(address _owner) public override view returns (uint256 balance) {
        return balances[_owner];
    }

   // Allows an address to approve another address to spend its tokens
    function approve(address _spender, uint256 _amount) public override returns (bool success) {
        // To change the approve amount you first have to reduce the addresses`
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
    

    //returns the allowance an address has granted a spender
    function allowance(address _owner, address _spender
    ) public view override returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
}
