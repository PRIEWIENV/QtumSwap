const Client = require('bitcoin-core')
var address = '2N7zWpgzJXb5M7KjeybmhyUJWFk8HqEF1en'

// root@btc@47.52.22.90:18443
const client = new Client({
  host: '47.52.22.90',
  port: 18443,
  username: 'root',
  password: 'btc',
  version: '0.16.2'
})

function getBalance () {
  client.listUnspent(1, 9999999, [address]).then((utxos) => {
    console.log(utxos)
    var balance = 0
    if (!(utxos.length === 0)) {
      for (var id in utxos) {
        if (utxos[id].solvable || utxos[id].spendible) {
          balance += utxos[id].amount
        }
      }
      console.log(balance)
    }
  }).catch(err => {
    console.log('error', err)
  })
}

module.exports = {
  getBalance: getBalance
}
