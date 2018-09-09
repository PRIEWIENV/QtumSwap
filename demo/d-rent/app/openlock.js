// assume: node 8 or above
const {
    Qtum,
  } = require("qtumjs")
  
const repoData = require("./solar.json")
const qtum = new Qtum("http://qtum:test@47.52.22.90:3889", repoData)
const market = qtum.contract("contracts/Market.sol")

const account='qHrZn3GHp9spToTFkjZ4cfbzdDThw3pLce'

async function openLock(key,houseNum){
    console.log("start unlock")
    var logs=await market.send('unlock',[key,houseNum],{senderAddress:account})
    console.log(logs)
}

$(".open-btn").click( function() {
    openLock("2", 1)
})