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


contract Market is Owned{
    using SafeMath for uint256;
    
    mapping(address => bool) isLandlord;
    address[] landlords;
    
    struct House{
        State _state;
        uint256 price;
        address owner;
        address user;
        bytes32 hash_;
        uint256 rentTime;
        uint256 isRentdate;
    }
    
    enum State {newHouse, onRent, isRent}
    
    House[] houses;

    modifier Exist(uint256 i){require(houses[i].owner!=0x0);_;}

    event logBeginRent(uint256 houseNum, address owner, uint256 price, bytes32 _hash);
    event logBook(uint256 houseNum, uint256 endTime, address user, uint256 price, bytes32 _hash);
    event logUnlock(uint256 houseNum, uint256 nowtime, uint256 endTime, address user_, string s_k);
    event RecoverHouse(uint256 houseNum, uint256 nowTime, address owner);
    
    
    constructor() public {
        owner = msg.sender;
        admins[msg.sender] = true;
    }
    
    function setLandlord(address _addr, bool _bool) public onlyAdmins {
        require(isLandlord[_addr] != _bool);
        
        if (_bool){
            landlords.push(_addr);
            isLandlord[_addr] = _bool;
        } else {
            for(uint256 i = 0; i < landlords.length; i++) {
                if(landlords[i] == _addr){
                    landlords[i] = landlords[landlords.length - 1];
                    delete landlords[landlords.length - 1];
                    landlords.length--;
                    isLandlord[_addr] = _bool;
                    // TODO 还需要下架他对应的房源 
                    break;
                    
                }
            }
        }
    }
    
    
    function beginRent(uint256 price, bytes32 _hash, uint256 _rentTime) public {
        require(isLandlord[msg.sender]);
        House memory _house = House(State.onRent, price, msg.sender, 0x0, _hash, _rentTime, 0);
        
        houses.push(_house);
        emit logBeginRent(houses.length-1, msg.sender, price, _hash);
    }
    
    function book(uint256 houseNum, bytes32 hidx, uint256 _rentTime) public Exist(houseNum) {
        House storage h = houses[houseNum];
        require(h._state == State.onRent && h.user == 0x0);
        require(h.hash_ == hidx);
        require(h.rentTime == _rentTime);
        
        h.user = msg.sender;
        h._state = State.isRent;
        h.isRentdate = now;
        uint256 _endTime = h.isRentdate.add(h.rentTime);
        
        emit logBook(houseNum, _endTime, msg.sender, h.price, hidx);
    }
    
    function unlock(string s_k, uint256 _houseNum) public Exist(_houseNum) {
        House storage h = houses[_houseNum];
        uint256 _endTime =  h.isRentdate.add(h.rentTime);
        require(h._state == State.isRent);
        require(h.user == msg.sender);
        require(now <= _endTime);
        require(keccak256(abi.encodePacked(s_k)) == h.hash_);
        
        
        emit logUnlock(_houseNum, now, _endTime, h.user, s_k);
    }
    
    function recoverHouse(uint256 houseNum) public Exist(houseNum) {
        House storage h = houses[houseNum];
        uint256 _endTime =  h.isRentdate.add(h.rentTime);
        uint256 _length = houses.length;
        
        require(h.owner == msg.sender);
        require(now > _endTime);
        
        h = houses[_length - 1];
        delete houses[_length - 1];
        houses.length--;
        
        emit RecoverHouse(houseNum, now, msg.sender);
    }
    
    function getHouseInfo(uint256 houseNum) public view returns(State, uint256, address, address, bytes32, uint256, uint256){
        House memory h=houses[houseNum];
        
        return (h._state, h.price, h.owner, h.user, h.hash_, h.rentTime, h.isRentdate);
    }
    
    
}