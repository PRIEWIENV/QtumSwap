pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

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


/**
 * @title AddressUtils
 * @dev Utility library of inline functions on addresses
 */
library AddressUtils {

    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param addr address to check
     * @return whether the target address is a contract
     */
    function isContract(address addr) 
        internal 
        view 
        returns (bool) 
    {
        uint256 size;
        /// @dev XXX Currently there is no better way to check if there is 
        // a contract in an address than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solium-disable-next-line security/no-inline-assembly
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}


/**
 * @title Owned
 */
contract Owned {
    address public owner;
    address public newOwner;
    mapping (address => bool) public admins;

    event OwnershipTransferred(
        address indexed _from, 
        address indexed _to
    );

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAdmins {
        require(admins[msg.sender]);
        _;
    }

    function transferOwnership(address _newOwner) 
        public 
        onlyOwner 
    {
        newOwner = _newOwner;
    }

    function acceptOwnership() 
        public 
    {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }

    function addAdmin(address _admin) 
        onlyOwner 
        public 
    {
        admins[_admin] = true;
    }

    function removeAdmin(address _admin) 
        onlyOwner 
        public 
    {
        delete admins[_admin];
    }

}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Owned {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() 
        onlyAdmins 
        whenNotPaused 
        public 
    {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() 
        onlyAdmins 
        whenPaused 
        public 
    {
        paused = false;
        emit Unpause();
    }
}


/**
 * @title Gateway
 * @dev player recharge ERC20 token to BTC and oppesite operation
 * @dev only support recharge once a period.
 */
contract Gateway is Pausable {
    using SafeMath for uint256;
    using AddressUtils for address;

    event Recharge(address _from, address _to, uint256 indexed _amount, address _tokenAddress, bytes32 _hash, uint256 _lockTime);
    event Withdraw(address _from, address _to, uint256 indexed _amount, address _tokenAddress, bytes32 _hash);
    event BackTo(address _from, uint256 indexed _amount, address _tokenAddress, bytes32 _hash);

    uint256 public minLockTime = 2 days;
    uint256 public maxLockTime = 5 days;

    uint256 public minLockTime2 = 0.5 days;
    uint256 public maxLockTime2 = 1 days;

    mapping (address => Locker) lockers;

    struct Locker{
        uint256 startTime;
        uint256 lockTime;
        uint256 amount;
        bytes32 hashStr;
        address tokenAddress;
        address to;
    }


    constructor() public {
        owner = msg.sender;
        admins[msg.sender] = true;
    }



    function setLockTime(bool isMin, uint256 _time)
        public
        onlyAdmins
    {
        if(isMin) {
            minLockTime = _time;
        } else {
            maxLockTime = _time;
        }
        
    }


    function setLockTime2(bool isMin, uint256 _time)
        public
        onlyAdmins
    {
        if(isMin) {
            minLockTime2 = _time;
        } else {
            maxLockTime2 = _time;
        }
        
    }    


    /**
     * @dev Hashed Timelock Contracts
     */
    function recharge(bytes32 _hash, uint256 _amount, address _tokenAddr, address _to, uint256 _lockTime) 
        public
        whenNotPaused
    {
        require(_tokenAddr.isContract(), "error token address");
        require(_lockTime >= minLockTime && _lockTime <= maxLockTime, "error lockTime");

        ERC20Interface token = ERC20Interface(_tokenAddr);

        if(token.transferFrom(msg.sender, address(this), _amount)) {
            lockers[msg.sender].startTime = now;
            lockers[msg.sender].lockTime = _lockTime;
            lockers[msg.sender].amount = _amount;
            lockers[msg.sender].hashStr = _hash;
            lockers[msg.sender].tokenAddress = _tokenAddr;
            lockers[msg.sender].to = _to;
        }


        emit Recharge(msg.sender, _to, _amount, _tokenAddr, _hash, _lockTime);
    }

/*
    function recharge(address _addr, uint256 _amount)
        public
        onlyAdmins
    {
        blance[_addr] = blance[_addr].add(_amount);
        emit Recharge(_addr, _amount);
    }
*/
    function withdrawTo(string _key, address _from)
        public
        whenNotPaused
    {
        bytes32 _hash = keccak256(abi.encodePacked(_key));
        address _tokenAddr = lockers[_from].tokenAddress;
        require(_hash == lockers[_from].hashStr, "key error");
        require(_tokenAddr.isContract(), "error token address");        
        
        address _tokenAddress = lockers[_from].tokenAddress;

        ERC20Interface token = ERC20Interface(_tokenAddress);

        if(token.transfer(lockers[_from].to, lockers[_from].amount)) {
            delete lockers[_from];
            emit Withdraw(_from, lockers[_from].to, lockers[_from].amount, lockers[_from].tokenAddress, lockers[_from].hashStr);
        }
    }


    function recharge2(bytes32 _hash, uint256 _amount, address _tokenAddr, address _to, uint256 _lockTime) 
        public
        whenNotPaused
    {
        require(_tokenAddr.isContract(), "error token address");
        require(_lockTime >= minLockTime2 && _lockTime <= maxLockTime2, "error lockTime");

        ERC20Interface token = ERC20Interface(_tokenAddr);

        if(token.transferFrom(msg.sender, address(this), _amount)) {
            lockers[msg.sender].startTime = now;
            lockers[msg.sender].lockTime = _lockTime;
            lockers[msg.sender].amount = _amount;
            lockers[msg.sender].hashStr = _hash;
            lockers[msg.sender].tokenAddress = _tokenAddr;
            lockers[msg.sender].to = _to;
        }

        emit Recharge(msg.sender, _to, _amount, _tokenAddr, _hash, _lockTime);
    }


    function backTo(address _from)
        public
        whenNotPaused
    {
        require(lockers[_from].startTime.add(lockers[_from].lockTime) >= now, "locked");
        require(lockers[_from].tokenAddress.isContract(), "error token address");
        
        ERC20Interface token = ERC20Interface(lockers[_from].tokenAddress);
        
        if(token.transfer(_from, lockers[_from].amount)) {
            delete lockers[_from];
            emit BackTo(_from, lockers[_from].amount, lockers[_from].tokenAddress, lockers[_from].hashStr);
        }
    }
   

    function blanceOf(address _addr)
        public
        view
        returns (uint256)
    {
        require(lockers[_addr].startTime != 0, "not initial");        
        return lockers[_addr].amount;
    }

    function getHashOf(address _addr)
        public
        view
        returns (bytes32)
    {   
        require(lockers[_addr].startTime != 0, "not initial");
        return  lockers[_addr].hashStr;
    }

    function getUnlockTime(address _addr)
        public
        view
        returns (uint256)
    {
        uint256 _time = lockers[_addr].startTime.add(lockers[_addr].lockTime);
        require(_time >= now, "already end or not initial");

        return _time.sub(now); 
    }

    function getToAddr(address _addr)
        public
        view
        returns (address)
    {
        require(lockers[_addr].startTime != 0, "not initial");
        return lockers[_addr].to;        
    }

    function getTokenAddr(address _addr)
        public
        view
        returns (address)
    {
        require(lockers[_addr].startTime != 0, "not initial");
        return lockers[_addr].tokenAddress;
    }

    // DEVELOP MODE
    event Test(address indexed _addr, uint256 indexed _i, bool _bool, bytes32 indexed _bytes32);
    function testEvent(address _addr, uint256 _i, bool _bool, bytes32 _bytes32) 
        public 
    {
    	emit Test(_addr, _i, _bool, _bytes32);
    }

}

interface ERC20Interface {
    function transfer(address to, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);
}