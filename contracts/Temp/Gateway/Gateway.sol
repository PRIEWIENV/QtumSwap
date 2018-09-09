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
 * @title Gateway
 * @dev player recharge ERC20 token to BTC and oppesite operation
 * @dev only support recharge once a period.
 */
contract Gateway  {
    using SafeMath for uint256;

    event Recharge(address _from, address _to, uint256 indexed _amount, address _tokenAddress, bytes32 _hash, uint256 _lockTime);
    event Withdraw(address _from, address _to, uint256 indexed _amount, address _tokenAddress, bytes32 _hash);
    event BackTo(address _from, uint256 indexed _amount, address _tokenAddress, bytes32 _hash);

    uint256 public minLockTime = 2 days;
    uint256 public maxLockTime = 5 days;

    uint256 public minLockTime2 = 0.5 days;
    uint256 public maxLockTime2 = 1 days;

    mapping (address => Locker) lockers;
    address test; // dev mode
    
    struct Locker{
        uint256 startTime;
        uint256 lockTime;
        uint256 amount;
        bytes32 hashStr;
        address tokenAddress;
        address to;
    }


    constructor() public {

    }



    function setLockTime(bool isMin, uint256 _time)
        public
    {
        if(isMin) {
            minLockTime = _time;
        } else {
            maxLockTime = _time;
        }
        
    }


    function setLockTime2(bool isMin, uint256 _time)
        public
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
    {

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
    {
        bytes32 _hash = keccak256(abi.encodePacked(_key));
        lockers[_from].hashStr = _hash;
        
        address _tokenAddress = lockers[_from].tokenAddress;

        ERC20Interface token = ERC20Interface(_tokenAddress);

        if(token.transfer(lockers[_from].to, lockers[_from].amount)) {
            delete lockers[_from];
            emit Withdraw(_from, lockers[_from].to, lockers[_from].amount, lockers[_from].tokenAddress, lockers[_from].hashStr);
        }
    }


    function recharge2(bytes32 _hash, uint256 _amount, address _tokenAddr, address _to, uint256 _lockTime) 
        public
    {

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
    {
        
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
        return lockers[_addr].amount;
    }

    function getHashOf(address _addr)
        public
        view
        returns (bytes32)
    {   
        return  lockers[_addr].hashStr;
    }

    function getUnlockTime(address _addr)
        public
        view
        returns (uint256)
    {
        uint256 _time = lockers[_addr].startTime.add(lockers[_addr].lockTime);

        return _time.sub(now); 
    }

    function getToAddr(address _addr)
        public
        view
        returns (address)
    {
        return lockers[_addr].to;        
    }

    function getTokenAddr(address _addr)
        public
        view
        returns (address)
    {
        return lockers[_addr].tokenAddress;
    }

}

interface ERC20Interface {
    function transfer(address to, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);
}