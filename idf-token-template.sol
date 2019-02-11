pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// Identity non-traction token
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

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
        owner = <@>contract_owner</@>;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract <@>contract_name</@>Token is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint256 public maxSupply;
    uint public _totalSupply;
    string public crowdTraction;
    string public dividendType;
    uint public bonus1Ends;
    uint public bonus2Ends;
    uint public endDate;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function <@>contract_name</@>Token() public {
        symbol = "<@>token_symbol</@>";
        name = "<@>token_name</@>";
        decimals = <@>token_decimals</@>;
        maxSupply = <@>max_supply</@>;
        crowdTraction = "<@>crowd_traction</@>";
        dividendType = "<@>dividend_payout</@>";
        bonus1Ends = now + <@>discount_days_1</@> days;
        bonus2Ends = now + <@>discount_days_1</@> days + <@>discount_days_2</@> days;
        endDate = now + <@>sale_days</@> days;

    }


    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }

    // ------------------------------------------------------------------------
    // Crowd traction
    // ------------------------------------------------------------------------
    function getCrowdTractionType() public constant returns (string) {
        return crowdTraction;
    }

    // ------------------------------------------------------------------------
    // Dividend payout
    // ------------------------------------------------------------------------
    function getDividendType() public constant returns (string) {
        return dividendType;
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {

        require(tokens <= balances[msg.sender]);
        require(to != address(0));

        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // <@>price</@> <@>token_symbol</@> Tokens per 1 ETH
    // ------------------------------------------------------------------------
    function () public payable {
        //check if sale not finished
        require(now <= endDate);

        uint tokens;

        //token price calculation
        if (now <= bonus1Ends) {
            tokens = msg.value * <@>discount_price_1</@>;
        } else if (now <= bonus2Ends) {
            tokens = msg.value * <@>discount_price_2</@>;
        } else {
            tokens = msg.value * <@>price</@>;
        }

        // maxSupply check
        require(safeAdd(_totalSupply, tokens) < maxSupply);

        balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
        _totalSupply = safeAdd(_totalSupply, tokens);
        Transfer(address(0), msg.sender, tokens);
        owner.transfer(msg.value);
    }

    function emitToSomeone(address to, uint256 tokens) public payable {

        require(to != address(0));

        require(msg.sender == owner);
        // maxSupply check
        require(safeAdd(_totalSupply, tokens) < maxSupply);

        if (msg.sender == owner) {
            balances[to] = safeAdd(balances[to], tokens);
            _totalSupply = safeAdd(_totalSupply, tokens);
            Transfer(address(0), to, tokens);
        }

    }


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}
