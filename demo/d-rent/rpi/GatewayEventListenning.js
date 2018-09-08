const {
  Qtum,
} = require("qtumjs")

const repoData = require("./solar.development.json")
const qtum = new Qtum("http://qtum:test@localhost:3889", repoData)
const gateway = qtum.contract("contracts/Gateway.sol")

async function streamEvents() {
  console.log("Subscribed to contract events")
  console.log("Ctrl-C to terminate events subscription")

  gateway.onLog((entry) => {
	var body=entry.event;
	switch(body.type){
		case 'Recharge':
			result={
				"type":0,
				"from":body._from,
				"to":body._to,
				"amount":body._amount,
				"token_address":body._tokenAddress,
				"hash":body._hash,
				"lock_time":body._lockTime
			}
			break;
		case 'Withdraw':
			result={
				"type":1,
				"from":body._from,
				"to":body._to,
				"amount":body._amount,
				"token_address":body._tokenAddress,
				"hash":body._hash
			}
			break;
		case 'BackTo':
			result={
				"type":2,
				"from":body._from,
				"amount":body._amount,
				"token_address":body._tokenAddress,
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

async function main() {
      await streamEvents()
}

main().catch(err => {
  console.log("error", err)
})

