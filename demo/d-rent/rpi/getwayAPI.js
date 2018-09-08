const {
  Qtum,
} = require("qtumjs")

const repoData = require("./solar.development.json")
const qtum = new Qtum("http://qtum:test@localhost:3889", repoData)
const gateway = qtum.contract("contracts/Gateway.sol")
const accountA="eb8929ae84dcca32cdd6745d4687acb302fe4b2a";
const accountB="dfa5e33ce6807ea71e45111a48958081dcdb2621";
const tokenAddress='5e447adeda0bef725a7e6075385e2c365e7fac52';
const _hash="0x70d8ec2972566c02373ce9102a51bd1f6c23bfaed911baeb55b17b079600438f";
const key="flyq";

async function setLockTime(isMin,_time){
	const logs=await gateway.send('setLockTime',[isMin,_time],{senderAddress:accountA})
	console.log(logs)
}

async function setLockTime2(isMin,_time){
	const logs=await gateway.send('setLockTime2',[isMin,_time],{senderAddress:accountA})
	console.log(logs)
}

async function recharge(_hash,_amount,_tokenAddress,_to,_lockTime){
	const logs=await gateway.send('recharge',[_hash,_amount,_tokenAddress,_to,_lockTime],{senderAddress:accountA})
	console.log(logs)
}

async function withdrawTo(_key,_from){
	const logs=await gateway.send('withdrawTo',[_key,_from],{senderAddress:accountB})
	console.log(logs)
}

async function recharge2(_hash,_amount,_tokenAddress,_to,_lockTime){
	const logs=await gateway.send('recharge2',[_hash,_amount,_tokenAddress,_to,_lockTime])
	console.log(logs)
}

async function backTo(_from){
	const logs=await gateway.send('backTo',[_from])
	console.log(logs)
}

async function getBalanceOf(_addr){
	const result=await gateway.call('balanceOf',[_addr])
	return result.outputs[0];
}

async function getHashOf(_addr){
	const result=await gateway.call('getHashOf',[_addr])
	return result.outputs[0];
}

async function getUnlockTime(_addr){
	const result=await gateway.call('getUnlockTime',[_addr])
	return result.outputs[0];
}

async function getToAddress(_addr){
	const result=await gateway.call('getToAddress',[_addr])
	return result.outputs[0];
}

async function getTokenAddress(_addr){
	const result=await gateway.call('getTokenAddress',[_addr])
	return result.outputs[0];
}
/*//for test
async function test(){
	recharge(_hash,1,tokenAddress,accountB,50000)
	withdrawTo(key,accountA)
	await getHashOf(accountA)
	console.log(await getHashOf(accountA))
	console.log(await getBalanceOf(accountA))
	console.log(await getUnLockTime(accountA))
	console.log(await getToAddress(accountA))
}

test().catch(err=>console.log(err))
*/
