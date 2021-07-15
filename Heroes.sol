pragma solidity ^0.5.0;

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
//
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Bought(uint256 amount);
}

// ----------------------------------------------------------------------------
// Safe Math Library
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a); c = a - b; } function safeMul(uint a, uint b) public pure returns (uint c) { c = a * b; require(a == 0 || c / a == b); } function safeDiv(uint a, uint b) public pure returns (uint c) { require(b > 0);
        c = a / b;
    }
}


contract Heroes is ERC20Interface, SafeMath {
    string public name;
    string public symbol;
    uint8 public decimals; // 18 decimals is the strongly suggested default, avoid changing it
    address payable owner;
    address[] public owners;
    
    bool public locked;

    uint256 public _totalSupply;
    uint256 public transferlimit;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    modifier onlyOwner() {
      require(msg.sender == owner);
      _;
    }

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor() public {
        name = "Heroes Test";
        symbol = "HRS Test";
        decimals = 18;
        _totalSupply = 100000000000000000000000000;
        owner = msg.sender;
        owners.push(owner);
        transferlimit = 50000000000000000000000000;
        locked = false;

        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    function changeTransferlimit(uint256 _transferlimit) external onlyOwner returns (bool) {
        transferlimit = _transferlimit;
        return true;
    }
    
    function lockTransactions(bool _locked) external onlyOwner returns (bool) {
        locked = _locked;
        return true;
    }


    function transfer(address to, uint tokens) public returns (bool success) {
        require(!locked, "Transactions are locked!");
        require(tokens <= transferlimit, "you can't transfer that much");
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        owners.push(msg.sender);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(!locked, "Transactions are locked!");
        require(tokens <= transferlimit, "you can't transfer that much");
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        owners.push(msg.sender);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    
    function() external payable {
        buyToken();
    }

    
    function buyToken() public payable {
        //buy a token
        // send ether to the wallet
        require(!locked, "Transactions are locked!");
        uint256 amountTobuy = msg.value  / 1000000000000000;
        require(amountTobuy > 0, "Minimal transaction is 0.1 ether");
        balances[msg.sender] += amountTobuy; // whoever calls this function will receive token
        owners.push(msg.sender);
        owner.transfer(msg.value);
        emit Bought(amountTobuy);
    }

}