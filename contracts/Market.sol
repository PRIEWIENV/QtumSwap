pragma solidity^0.4.24;

contract Market{
    struct House{
        //bytes32 secret;
        uint timeline;
        uint price;
        address owner;
        address user;
    }
    
    mapping(bytes32=>House) houses;
    
    modifier OnlyUser(bytes32 hidx){require(houses[hidx].user==msg.sender);_;}
    modifier OnlyAfter(bytes32 hidx){require(now>houses[hidx].timeline);_;}
    modifier OnlyBefore(bytes32 hidx){require(now<=houses[hidx].timeline);_;}
    modifier Exist(bytes32 hidx){require(houses[hidx].owner!=0x0);_;}
    modifier NotExist(bytes32 hidx){require(houses[hidx].owner==0x0);_;}
    //modifier checkHash(bytes32 hidx,bytes32 h){require(h==houses[hidx].secret);_;}
    
    event logUnlock(uint time,address user,uint t2,bool success);
    event logBook(uint time,address user,uint price,uint timeline);
    event logRentOut(uint time,address owner,bytes32 hidx,uint price);
    
    function Market(){
    }
    
    function() payable{}
    
    function rentOut(address owner,uint price,bytes32 hidx) NotExist(hidx){
        houses[hidx]=House(now,price,owner,0x0);
        logRentOut(now,owner,hidx,price);
    }
    
    function book(address customer,uint time,bytes32 hidx) public payable Exist(hidx) OnlyAfter(hidx){
        House storage h=houses[hidx];
        h.user=customer;
        h.timeline=time;
        address owner=h.owner;
        owner.transfer(h.price);
        logBook(now,customer,h.price,time);
    }
    
    function unlock(bytes32 hidx)public OnlyUser(hidx) Exist(hidx) OnlyBefore(hidx){
        House h=houses[hidx];
        logUnlock(now,h.user,h.timeline,true);
    }
    
    function getHouseInfo(bytes32 hidx)public returns(uint,uint,address,address){
        House h=houses[hidx];
        return(h.timeline,h.price,h.owner,h.user);
    }
    
    function getUser(bytes32 hidx)public returns(address){
        return houses[hidx].user;
    }
    
    function getPrice(bytes32 hidx) public returns(uint){
        return houses[hidx].price;
    }
    
    function getTimeLine(bytes32 hidx) public returns(uint){
        return houses[hidx].timeline;
    }
    
    function getOwner(bytes32 hidx) public returns(address){
        return houses[hidx].owner;
    }
    
}