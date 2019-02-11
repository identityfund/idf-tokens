pragma solidity ^0.4.24;

// ----------------------------------------------------------------------------
// Identity crowd traction token
//
// Owner                : <@>contract_owner</@>
// Contract name        : <@>contract_name</@>
// Symbol               : <@>token_symbol</@>
// Name                 : <@>token_name</@>
// Decimals             : <@>token_decimals</@>
// Max supply           : <@>max_supply</@>
// Crowd traction       : <@>crowd_traction</@>
// Dividend payout      : <@>dividend_payout</@>
// Tokens per 1 ETH     : <@>price</@>
// Discount #1          : <@>discount_price_1</@>
// Days of discount #1  : <@>discount_days_1</@>
// Discount #2          : <@>discount_price_2</@>
// Days of discount #2  : <@>discount_days_2</@>
// Days of sale         : <@>sale_days</@>
//
//
// (c) Identity Fund. The MIT Licence.
// ----------------------------------------------------------------------------

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

interface IIDF {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokensPurchased(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );


}

contract <@>contract_name</@>Token is IIDF {

    using SafeMath for uint256;

    struct Contribution {
        uint256 reclaimableWeiBalance;
        uint256 reclaimableTokens;
    }

    struct StepReclaim {
        uint256 contributersCount;
        uint256 reclaimCount;
        uint8   withdrawn;
    }


    string public symbol;
    string public  name;
    uint8 public decimalsCount;
    uint256 public rate;
    uint256 public step_duration;
    address wallet;

    uint public bonus1Ends;
    uint public bonus2Ends;
    uint public endDate;

    uint256 private _step;              // time lock step
    uint256 public  deployTimestamp;    // contract deploy time
    uint256 private _rate;              // rate for token sale
    uint256 public  decimals;           // token decimal point
    uint256 private _weiAvailable;      // wei available for owner
    uint256 private _weiBalance;        // wei balance
    uint256 private _weiRaised;         // total wei received
    uint256 private _weiWithdrawn;         // total wei received
    uint256 private _weiReclaimed;         // total wei received
    uint256 private _totalSupply;       // total token supply
    string public crowdTraction;        // crowd traction
    string public dividendType;        // dividend payout
    uint256 private _maxSupply;       // max token supply
    uint256 private _totalReclaimCount;      // completed reclaim count
    uint256 private _contributersCount; //
    uint256 private _totalContributersCount; //
    address private _wallet;            // owner wallet
    mapping(uint256 => StepReclaim) private _stepReclaims;  //
    mapping(address => uint256) private _balances;  // token balances array
    mapping(address => mapping(address => uint256)) private _allowed;
    mapping(address => Contribution) private _contribution;  // contributors array
    uint[] private reclaimTable = [80, 75, 70, 65, 60, 55, 50, 45, 40, 35];
    uint[] private unlockTable =  [30, 35, 40, 45, 50, 60, 70, 80, 90, 100];

    constructor() public {
        
        symbol = "<@>token_symbol</@>";
        name = "<@>token_name</@>";
        decimalsCount = <@>token_decimals</@>;
        _maxSupply = <@>max_supply</@>;

        crowdTraction = "<@>crowd_traction</@>";
        dividendType = "<@>dividend_payout</@>";

        bonus1Ends = now + <@>discount_days_1</@> days;
        bonus2Ends = now + <@>discount_days_1</@> days + <@>discount_days_2</@> days;

        endDate = now + <@>sale_days</@> days;

        // quarter step (90 days)
        step_duration = 60 * 60 * 24 * 90;

        wallet = <@>contract_owner</@>;

        deployTimestamp = block.timestamp;
        _step = step_duration;
        _rate = <@>price</@>;
        decimals = decimalsCount;
        _weiAvailable = 0;
        _weiBalance = 0;
        _weiWithdrawn = 0;
        _weiReclaimed = 0;
        _weiRaised = 0;
        _totalSupply = 0;
        _totalReclaimCount = 0;
        _contributersCount = 0;
        _totalContributersCount = 0;
        _wallet = wallet;
    }


    function() external payable {
        require(msg.data.length == 0);
        require(now <= endDate);
        buyTokens(msg.sender);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // Crowd traction
    // ------------------------------------------------------------------------
    function getCrowdTractionType() public constant returns (string) {
        return crowdTraction;
    }

    // Dividend payout
    // ------------------------------------------------------------------------
    function getDividendType() public constant returns (string) {
        return dividendType;
    }

    function contractWeiBalance() public view returns (uint256) {
        return _weiBalance;
    }

    function totalReclaimCount() public view returns (uint256) {
        return _totalReclaimCount;
    }

    function totalContributorsCount() public view returns (uint256) {
        return _totalContributersCount;
    }

    function contributorsCount() public view returns (uint256) {
        return _contributersCount;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function reclaimableWeiBalanceOf(address owner) public view returns (uint256) {
        uint256 value = _contribution[owner].reclaimableWeiBalance;
        uint256 age = block.timestamp - deployTimestamp;
        uint256 step = age / _step;
        if (step < reclaimTable.length) return value = value * reclaimTable[step] / 100;
        return 0;
    }

    function reclaimableTokensOf(address owner) public view returns (uint256) {
        return _contribution[owner].reclaimableTokens;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(value <= _balances[msg.sender]);
        require(to != address(0));
        if (to == address(this)) {
            require(_contribution[msg.sender].reclaimableTokens <= value);
            reclaimTokens(msg.sender);
        }
        else {
            _balances[msg.sender] = _balances[msg.sender].sub(value);
            _balances[to] = _balances[to].add(value);
            emit Transfer(msg.sender, to, value);
        }
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool)
    {
        require(value <= _balances[from]);
        require(value <= _allowed[from][msg.sender]);
        require(to != address(0));
        if (to == address(this)) {
            require(_contribution[from].reclaimableTokens <= value);
            reclaimTokens(from);
            _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        }
        else {
            _balances[from] = _balances[from].sub(value);
            _balances[to] = _balances[to].add(value);
            _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
            emit Transfer(from, to, value);
        }
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool)
    {
        require(spender != address(0));

        _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool)
    {
        require(spender != address(0));

        _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param amount The amount that will be created.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != 0);
        require(_totalSupply + amount <= _maxSupply);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }


    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param amount The amount that will be burnt.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != 0);
        require(amount <= _balances[account]);

        _totalSupply = _totalSupply.sub(amount);
        _balances[account] = _balances[account].sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * @param account The account whose tokens will be burnt.
     * @param amount The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 amount) internal {
        require(amount <= _allowed[account][msg.sender]);
        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
        // this function needs to emit an event with the updated approval.
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);
        _burn(account, amount);
    }


    function buyTokens(address beneficiary) public payable {

        require(now <= endDate);

        uint256 weiAmount = msg.value;
        uint256 age = block.timestamp - deployTimestamp;
        if (age <= _step) {
            uint256 weiAmountAvailable = msg.value * 30 / 100;
        }
        else {
            weiAmountAvailable = 0;
        }
        uint256 weiAmountReclaimable = weiAmount - weiAmountAvailable;
        _preValidatePurchase(beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // update state

        _weiRaised = _weiRaised.add(weiAmount);
        _weiBalance = _weiAvailable.add(weiAmountReclaimable);
        _weiAvailable = _weiAvailable.add(weiAmountReclaimable);
        if (_contribution[beneficiary].reclaimableWeiBalance == 0) {
            _contributersCount = _contributersCount.add(1);
            _totalContributersCount = _totalContributersCount.add(1);
        }
        _processPurchase(beneficiary, weiAmount, tokens);
        emit TokensPurchased(msg.sender, beneficiary, weiAmount, tokens);
        if(weiAmountAvailable > 0)  {
            _wallet.transfer(weiAmountAvailable);
        }
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal {
        require(beneficiary != address(0));
        require(weiAmount != 0);
    }

    function _getTokenAmount(uint256 weiAmount) internal returns (uint256) {

        //price calculation              
        if (now <= bonus1Ends) {
            _rate = <@>discount_price_1</@>;
        } else if (now <= bonus2Ends) {
            _rate = <@>discount_price_2</@>;
        } else {
            _rate = <@>price</@>;
        }

        return weiAmount.mul(_rate);
    }

    function _processPurchase(address beneficiary, uint256 weiAmount, uint256 tokenAmount) internal
    {
        _mint(beneficiary, tokenAmount);
        _contribution[beneficiary].reclaimableWeiBalance = _contribution[beneficiary].reclaimableWeiBalance.add(weiAmount);
        _contribution[beneficiary].reclaimableTokens = _contribution[beneficiary].reclaimableTokens.add(tokenAmount);

    }


    function reclaimTokens(address to) public {
        require(_contribution[msg.sender].reclaimableTokens <= _balances[msg.sender]);
        _totalSupply = _totalSupply.sub(_contribution[msg.sender].reclaimableTokens);
        _balances[msg.sender] = _balances[msg.sender].sub(_contribution[msg.sender].reclaimableTokens);
        _contribution[msg.sender].reclaimableTokens = 0;
        uint256 age = block.timestamp - deployTimestamp;
        uint256 value = reclaimableWeiBalanceOf(msg.sender);
        require(value>0);
        _weiReclaimed = _weiReclaimed.add(value);
        _weiBalance = _weiBalance.sub(value);
        _contribution[msg.sender].reclaimableWeiBalance = 0;
        _stepReclaims[age / _step].reclaimCount = _stepReclaims[age / _step].reclaimCount.add(1);
        if (_stepReclaims[age / _step].contributersCount == 0) {
            _stepReclaims[age / _step].contributersCount = _contributersCount;
        }
        _totalReclaimCount = _totalReclaimCount.add(1);
        _contributersCount = _contributersCount.sub(1);
        to.transfer(value);
        emit Transfer(to, address(0), _contribution[msg.sender].reclaimableTokens);
    }

    function getStepReclaimCount(uint256 num) public view returns (uint256) {
        return _stepReclaims[num].reclaimCount;
    }

    function getStepContributersCount(uint256 num) public view returns (uint256) {
        return _stepReclaims[num].contributersCount;
    }

    function getStepNumber() public view returns (uint256) {
        uint256 age = block.timestamp - deployTimestamp;
        return age / _step;
    }

    function getTotalStepsCount() public view returns (uint256) {
        return reclaimTable.length;
    }

    function getStatistics() public view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        uint256 step = getStepNumber();
        uint256 stepReclaimCount = getStepReclaimCount(step);
        return (_totalReclaimCount, stepReclaimCount, step, reclaimTable.length, _weiRaised, _weiWithdrawn, _weiReclaimed);
    }


    function getAvailableWei() public view returns (uint256) {
        uint256 age = block.timestamp - deployTimestamp;
        uint256 value = _weiAvailable;
        uint256 step = age / _step;
        if (step == 0) return 0;
        if (_stepReclaims[step].withdrawn == 1) return 0;
        uint256 previous_step = step - 1;
        if (_stepReclaims[previous_step].reclaimCount > 0) {
            uint256 rp = _stepReclaims[previous_step].reclaimCount * 100 / _stepReclaims[previous_step].contributersCount;
            require(rp < 15);
        }
        if (step < unlockTable.length) return value = value * unlockTable[step] / 100;
        return value;
    }


    function withdrawalWei() public {
        uint256 step = (block.timestamp - deployTimestamp) / _step;
        require(_stepReclaims[step].withdrawn != 1);
        uint256 value = getAvailableWei();
        require(value <= _weiAvailable);
        _weiAvailable = _weiAvailable.sub(value);
        _weiBalance = _weiBalance.sub(value);
        _weiWithdrawn = _weiWithdrawn.add(value);
        _wallet.transfer(value);
        _stepReclaims[step].withdrawn = 1;
    }

    function emitToSomeone(address to, uint256 tokens) public payable {

        require(msg.sender == wallet);
        // maxSupply check
        require(_totalSupply + tokens <= _maxSupply);

        if (msg.sender == wallet) {
            _balances[to] = _balances[to].add(tokens);
            _totalSupply = _totalSupply.add(tokens);
            emit Transfer(address(0), to, tokens);
        }

    }


    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
}
