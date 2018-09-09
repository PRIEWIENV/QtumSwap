// assume: node 8 or above
const {
    Qtum,
  } = require("qtumjs")
  
const repoData = require("./solar.json")
const qtum = new Qtum("http://qtum:test@47.52.22.90:3889", repoData)
const market = qtum.contract("contracts/Market.sol")

const account='qHrZn3GHp9spToTFkjZ4cfbzdDThw3pLce'

// 30
async function book(houseNum,hidx,_rentTime){
  console.log("start book")
  var logs=await market.send('book',[houseNum,hidx,_rentTime],{senderAddress:account})
  console.log(logs)
}

async function streamEvents() {
console.log("Subscribed to contract events")
console.log("Ctrl-C to terminate events subscription")

market.onLog((entry) => {
    var body=entry.event;
    switch(body.type){
        case 'logBook':
            result={
                "type":1,
                "end_time":body.endTime,
                "user":body.user,
                "price":body.price,
                "hash":body._hash
            }
            break;
        default:
            result={
                "type":-1
            }
            break;
    }
    console.log(result);
}, { minconf: 1 })
}

async function bookRoom() {
  await book(1, "3", 30)
  await streamEvents()
}

$(".bookroom-btn").click( function() {
  bookRoom()
  window.location.href="receipt.html"
})