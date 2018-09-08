// assume: node 8 or above
const {
  Qtum,
} = require("qtumjs")

const repoData = require("./solar.json")
const qtum = new Qtum("http://qtum:test@localhost:3889", repoData)
const market = qtum.contract("contracts/Market.sol")

const account='qHrZn3GHp9spToTFkjZ4cfbzdDThw3pLce'

async function setLandLord(_addr,_bool){
	var logs=await market.send('setLandLord',[_addr,_bool])
	console.log(logs)
}

async function beginRent(price,_hash,_rentTime){
	var logs=await market.send('beginRent',[price,_hash,_rentTime])
	console.log(logs)
}

async function book(houseNum,hidx,_rentTime){
	var logs=await market.send('book',[houseNum,hidx,_rentTime],{senderAddress:account})
	console.log(logs)
}

async function unlock(key,houseNum){
	var logs=await market.send('unlock',[key,houseNum],{senderAddress:account})
	console.log(logs)
}

async function getHouseInfo(houseNum){
	var result=await market.call('getHouseInfo',[houseNum],{senderAddress:account})
	console.log(result.outputs)
	console.log(result.outputs[0])
	return result.outputs
}
