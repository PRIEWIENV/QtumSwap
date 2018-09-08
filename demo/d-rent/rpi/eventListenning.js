// assume: node 8 or above
const {
  Qtum,
} = require("qtumjs")

const repoData = require("./solar.json")
const qtum = new Qtum("http://root:qtum@localhost:3889", repoData)
const market = qtum.contract("contracts/Market.sol")

async function streamEvents() {
  console.log("Subscribed to contract events")
  console.log("Ctrl-C to terminate events subscription")

  market.onLog((entry) => {
	var body=entry.event;
	switch(body.type){
		case 'logUnlock':
			result={
				"type":2,
				"now_time":body.nowtime,
				"end_time":body.endTime,
				"user":body.user_,
				"key":body.s_k
			}
			break;
		case 'logBook':
			result={
				"type":1,
				"end_time":body.endTime,
				"user":body.user,
				"price":body.price,
				"hash":body._hash
			}
			break;
		case 'logBeginRent':
			result={
				"type":0,
				"house_amount":body.houseAmount,
				"owner":body.owner,
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

async function main() {
      await streamEvents()
}

main().catch(err => {
  console.log("error", err)
})

