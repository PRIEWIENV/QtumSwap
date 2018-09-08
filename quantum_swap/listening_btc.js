const Client = require('bitcoin-core');
var address = '2N7zWpgzJXb5M7KjeybmhyUJWFk8HqEF1en'
var address_b = 'nothing'
const script_temp = 'OP_HASH160 a1c1b33c526467766ac8b4b9ab07d912c2c9c732 OP_EQUAL'

//root@btc@47.52.22.90:18443
const client = new Client({
  host: '47.52.22.90',
  port: 18443,
  username: 'root',
  password: 'btc',
  version: '0.16.2'
});

setInterval(
  function() {
    client.listUnspent(1, 9999999, [address]).then((utxos) => {
      console.log(utxos)
      if (!(utxos.length === 0)) {
        for (id in utxos) {
          return client.getTxOut(utxos[id].txid, utxos[id].vout)
        }
      }
    }).then((tx) => {
      if (tx.scriptPubKey) {
        console.log(tx.scriptPubKey.asm)
        if (tx.scriptPubKey.asm === script_temp) {
          return 1
        }
      }
    })
  },
  10000
)
