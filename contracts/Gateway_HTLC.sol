pragma solidity ^0.4.24;

import "./SafeMath.sol";
import "./AddressUtils.sol";
import "./Pausable.sol";

/**
 * @title Gateway
 * @dev player recharge ERC20 token to BTC and oppesite operation
 * @dev only support recharge once a period.
 */
contract Gateway_HTLC is Pausable {
    using SafeMath for uint256;
    using AddressUtils for address;

    event Recharge(address _from, address _to, uint256 indexed _amount, address _tokenAddress, bytes32 _hash, uint256 _lockTime);
    event Withdraw(address _from, address _to, uint256 indexed _amount, address _tokenAddress, bytes32 _hash);
    event BackTo(address _from, uint256 indexed _amount, address _tokenAddress, bytes32 _hash);

    uint256 public minLockTime = 2 days;
    uint256 public maxLockTime = 5 days;

    uint256 public minLockTime2 = 0.5 days;
    uint256 public maxLockTime2 = 1 days;

    mapping (address => Locker[]) lockers;
    
    struct Locker {
        uint256 startTime;
        uint256 lockTime;
        uint256 amount; // erc20 & coin's amount or nft's tokenId
        bytes32 hashStr;
        address tokenAddress; // 如果是ETH，地址就是address(1); 为了避免和0地址重合
        address to;
    }


    constructor() public {
        owner = msg.sender;
        admins[msg.sender] = true;
    }



    function setLockTime(uint256 _type, uint256 _time)
        public
        onlyAdmins
    {
        if(_type == 1) {
            minLockTime = _time;
        } else if(_type == 2) {
            maxLockTime = _time;
        } else if(_type == 3) {
            minLockTime2 = _time;
        } else if(_type == 4) {
            maxLockTime2 = _time;
        } else {
            revert();
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
            Locker memory locker = Locker(now, _lockTime, _amount, _hash, _tokenAddr, _to);

            lockers[msg.sender].push(locker);
        }

        emit Recharge(msg.sender, _to, _amount, _tokenAddr, _hash, _lockTime);
    }


    /**
     * @dev Hashed Timelock Contracts
     * @dev Qtum, Eth, Eos and so on
     */
    function rechargeInCoin(bytes32 _hash, address _to, uint256 _lockTime) 
        public
        payable
    {
        require(_lockTime >= minLockTime && _lockTime <= maxLockTime, "error lockTime");

        uint256 _amount = msg.value;

        Locker memory locker = Locker(now, _lockTime, _amount, _hash, address(1), _to);

        lockers[msg.sender].push(locker);

        emit Recharge(msg.sender, _to, _amount, 0x0, _hash, _lockTime);
    }


    /**
     * @dev Hashed Timelock Contracts
     * @dev ERC721 token, NFT, ie:cryptokitties
     */
    function rechargeInNFT(bytes32 _hash, uint256 _tokenId, address _tokenAddr, address _to, uint256 _lockTime) 
        public
    {
        require(_tokenAddr.isContract(), "error token address");
        require(_lockTime >= minLockTime && _lockTime <= maxLockTime, "error lockTime");

        ERC721Interface token = ERC721Interface(_tokenAddr);

        token.transferFrom(msg.sender, address(this), _tokenId);

        Locker memory locker = Locker(now, _lockTime, _tokenId, _hash, _tokenAddr, _to);
        lockers[msg.sender].push(locker);

        emit Recharge(msg.sender, _to, _tokenId, _tokenAddr, _hash, _lockTime);
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
    /**
     * @dev _index is the index of address's locker.
     */
    function withdrawTo(string _key, address _from, uint256 _index)
        public
    {
        bytes32 _hash = keccak256(abi.encodePacked(_key));
        address _tokenAddr = lockers[_from][_index].tokenAddress;
        require(_hash == lockers[_from][_index].hashStr, "key error");
        require(_tokenAddr.isContract(), "error token address");        
        
        address _tokenAddress = lockers[_from][_index].tokenAddress;

        ERC20Interface token = ERC20Interface(_tokenAddress);

        if(token.transfer(lockers[_from][_index].to, lockers[_from][_index].amount)) {
            deleteLocker(_from, _index);
            emit Withdraw(_from, lockers[_from][_index].to, lockers[_from][_index].amount, lockers[_from][_index].tokenAddress, lockers[_from][_index].hashStr);
        }
    }

    function withdrawToInCoin(string _key, address _from, uint256 _index)
        public
    {
        bytes32 _hash = keccak256(abi.encodePacked(_key));
        lockers[_from][_index].hashStr = _hash;

        lockers[_from][_index].to.transfer(lockers[_from][_index].amount);
        deleteLocker(_from, _index);
        emit Withdraw(_from, lockers[_from][_index].to, lockers[_from][_index].amount, lockers[_from][_index].tokenAddress, lockers[_from][_index].hashStr);   
    }

    function withdrawToInNFT(string _key, address _from, uint256 _index) 
        public
    {
        bytes32 _hash = keccak256(abi.encodePacked(_key));
        lockers[_from][_index].hashStr = _hash;

        address _tokenAddress = lockers[_from][_index].tokenAddress;

        ERC20Interface token = ERC20Interface(_tokenAddress);

        if(token.transfer(lockers[_from][_index].to, lockers[_from][_index].amount)) {
            deleteLocker(_from, _index);
            emit Withdraw(_from, lockers[_from][_index].to, lockers[_from][_index].amount, lockers[_from][_index].tokenAddress, lockers[_from][_index].hashStr);
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
            Locker memory locker = Locker(now, _lockTime, _amount, _hash, _tokenAddr, _to);

            lockers[msg.sender].push(locker);
        }

        emit Recharge(msg.sender, _to, _amount, _tokenAddr, _hash, _lockTime);
    }

    /**
     * @dev Hashed Timelock Contracts
     * @dev Qtum, Eth, Eos and so on
     */
    function rechargeInCoin2(bytes32 _hash, address _to, uint256 _lockTime) 
        public
        payable
    {
        require(_lockTime >= minLockTime2 && _lockTime <= maxLockTime2, "error lockTime");

        uint256 _amount = msg.value;

        Locker memory locker = Locker(now, _lockTime, _amount, _hash, address(1), _to);

        lockers[msg.sender].push(locker);

        emit Recharge(msg.sender, _to, _amount, 0x0, _hash, _lockTime);
    }


    /**
     * @dev Hashed Timelock Contracts
     * @dev ERC721 token, NFT, ie:cryptokitties
     */
    function rechargeInNFT2(bytes32 _hash, uint256 _tokenId, address _tokenAddr, address _to, uint256 _lockTime) 
        public
    {
        require(_tokenAddr.isContract(), "error token address");
        require(_lockTime >= minLockTime2 && _lockTime <= maxLockTime2, "error lockTime");

        ERC721Interface token = ERC721Interface(_tokenAddr);

        token.transferFrom(msg.sender, address(this), _tokenId);

        Locker memory locker = Locker(now, _lockTime, _tokenId, _hash, _tokenAddr, _to);
        lockers[msg.sender].push(locker);

        emit Recharge(msg.sender, _to, _tokenId, _tokenAddr, _hash, _lockTime);
    }

    function deleteLocker(address _owner, uint256 _index)
        internal
    {
        uint256 len = lockers[_owner].length;
        lockers[_owner][_index]=lockers[_owner][len-1];
        delete lockers[_owner][len-1];
        lockers[_owner].length.sub(1);
    }

    function backTo(address _from, uint256 _index)
        public
        whenNotPaused
    {
        require(lockers[_from][_index].startTime.add(lockers[_from][_index].lockTime) >= now, "locked");
        require(lockers[_from][_index].tokenAddress.isContract(), "error token address");
        
        ERC20Interface token = ERC20Interface(lockers[_from][_index].tokenAddress);
        
        if(token.transfer(_from, lockers[_from][_index].amount)) {
            deleteLocker(_from, _index);
            emit BackTo(_from, lockers[_from][_index].amount, lockers[_from][_index].tokenAddress, lockers[_from][_index].hashStr);
        }
    }

    function backToInCoin(address _from, uint256 _index)
        public
        whenNotPaused
    {
        require(lockers[_from][_index].startTime.add(lockers[_from][_index].lockTime) >= now, "locked");
        require(lockers[_from][_index].tokenAddress == address(1), "error token address");
    
        
        _from.transfer(lockers[_from][_index].amount);

        deleteLocker(_from, _index);
        emit BackTo(_from, lockers[_from][_index].amount, lockers[_from][_index].tokenAddress, lockers[_from][_index].hashStr);
    }

    function backToInNFT(address _from, uint256 _index)
        public
        whenNotPaused
    {
        require(lockers[_from][_index].startTime.add(lockers[_from][_index].lockTime) >= now, "locked");
        require(lockers[_from][_index].tokenAddress.isContract(), "error token address");
        
        ERC721Interface token = ERC721Interface(lockers[_from][_index].tokenAddress);
        
        // amount standard for token ID
        token.transferFrom(address(this), _from, lockers[_from][_index].amount);
        deleteLocker(_from, _index);
        emit BackTo(_from, lockers[_from][_index].amount, lockers[_from][_index].tokenAddress, lockers[_from][_index].hashStr);
        
    
    }    
   

    function blanceOf(address _addr, uint256 _index)
        public
        view
        returns (uint256)
    {
        require(lockers[_addr][_index].startTime != 0, "not initial");        
        return lockers[_addr][_index].amount;
    }

    function getHashOf(address _addr, uint256 _index)
        public
        view
        returns (bytes32)
    {   
        require(lockers[_addr][_index].startTime != 0, "not initial");
        return  lockers[_addr][_index].hashStr;
    }

    function getUnlockTime(address _addr, uint256 _index)
        public
        view
        returns (uint256)
    {
        uint256 _time = lockers[_addr][_index].startTime.add(lockers[_addr][_index].lockTime);
        require(_time >= now, "already end or not initial");

        return _time.sub(now); 
    }

    function getToAddr(address _addr, uint256 _index)
        public
        view
        returns (address)
    {
        require(lockers[_addr][_index].startTime != 0, "not initial");
        return lockers[_addr][_index].to;        
    }

    function getTokenAddr(address _addr, uint256 _index)
        public
        view
        returns (address)
    {
        require(lockers[_addr][_index].startTime != 0, "not initial");
        return lockers[_addr][_index].tokenAddress;
    }

}

interface ERC20Interface {
    function transfer(address to, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);
}

interface ERC721Interface {
    function transferFrom(address from, address to, uint256 tokenId) external;
}