const {
  QtumRPC,
} = require("qtumjs")

var address = 'qfMtLsfjEBhHRsJjPwb5g7cWGE8m854fYq'
var address_b = 'nothing'
const script_temp = 'OP_HASH160 a1c1b33c526467766ac8b4b9ab07d912c2c9c732 OP_EQUAL'

const rpc = new QtumRPC("http://qtum:test@47.52.22.90:3889");

setInterval(
  function() {
    rpc.rawCall("listunspent", [1, 9999999, [address]]).then((utxos) => {
      //console.log(utxos)
      if (utxos.length === 0) {
        throw new Error("No UTXOs");
      } else {
        for (id in utxos) {
          return rpc.rawCall("gettxout", [utxos[id].txid, utxos[id].vout])
        }
      }
    }).then((tx) => {
      if (tx.scriptPubKey) {
        console.log(tx.scriptPubKey.asm)
        if (tx.scriptPubKey.asm === script_temp) {
          return 1
        }
      }
    }).catch(err => {
      console.log("error", err)
    })
  },
  10000
)