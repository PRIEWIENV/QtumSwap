const {
    PrivateKey,
    Opcode,
    Transaction,
    Script,
    Network,
    Address,
    crypto
} = require('bitcore');

var assert = require('assert');
//var transaction = new bitcore.Transaction();
//var transaction.from(unspent).to(address, amount);
//transaction.sign(privateKey);


var A_a_pk = new PrivateKey();
var A_a = A_a_pk.toAddress(); //A's Qtum address
var A_b_pk = new PrivateKey();
var A_b = A_b_pk.toAddress(); //A's BTC address


var B_a_pk = new PrivateKey();
var B_a = B_a_pk.toAddress(); //B's Qtum address
var B_b_pk = new PrivateKey();
var B_b = B_b_pk.toAddress(); //B's BTC address

/* OP_IF
 *      now+LOCKTIME OP_CLTV OP_DROP BPK OP_CHECKSIG
 * OP_ELSE
 *      OP_HASH160 SH OP_EQUALVERIFY APK OP_CHECKSIG
 * OP_ENDIF
 */


//var interpreter = bitcore.Script.Interpreter();
//interpreter.set({script: 'OP_2 OP_1 OP_SUB'});
//interpreter.evaluate();
//
var privateKey = new PrivateKey('L1uyy5qTuGrVXrmrsvHWHgVzW9kKdrp27wBC7Vs6nZDTF2BRUVwy');
var utxo = {
  "txId" : "115e8f72f39fad874cfab0deed11a80f24f967a84079fb56ddf53ea02e308986",
  "outputIndex" : 0,
  "address" : "17XBj6iFEsf8kzDMGQk5ghZipxX49VXuaV",
  "script" : "76a91447862fe165e6121af80d5dde1ecb478ed170565b88ac",
  "satoshis" : 50000
};

var transaction = new Transaction()
    .from(utxo)
    .addData('bitcore rocks') // Add OP_RETURN data
    .sign(privateKey);
console.log(transaction)

var now = Math.floor(Date.now() / 1000)
console.log(now)

var lock_time = 300 //5 min
console.log(lock_time)


// STEP 1 CREATE SECRET
var secret = new crypto.Random.getRandomBuffer(8);
var H_S = new crypto.Hash.sha256ripemd160(secret);
console.log(secret)
console.log(H_S)
console.log(typeof(H_S))

var address = new Address.fromString('2MxLCge4KshytFpprTPweb8zPsmG6nhAcun');
console.log(address)

// bitcore.Networks.enableRegtest();
// bitcore.Networks.testnet.networkMagic;
// var testnet = new bitcore.Network.testn
// _.extend(testnet, {
//       name: 'testnet',
//       alias: 'testnet',
//       pubkeyhash: 0x6f,
//       privatekey: 0xef,
//       scripthash: 0xc4,
//       xpubkey: 0x043587cf,
//       xprivkey: 0x04358394,
//       port: 18333
//
// });

var script = new Script()
  .add('OP_IF')                       // add an opcode by name
  .prepend(114)                       // add OP_2SWAP by code
  .add(Opcode.OP_NOT)                 // add an opcode object
  .add(new Buffer('bacacafe', 'hex')) // add a data buffer (will append the size of the push operation first)

assert(script.toString() === 'OP_2SWAP OP_IF OP_NOT 4 0xbacacafe');
console.log(script.toString());


var test_script = new Script()
    .add(Opcode.OP_IF)
    .add(now+lock_time*2)
    .add(Opcode.OP_CHECKLOCKTIMEVERIFY)
    .add(Opcode.OP_DROP)
    .add(B_b)
    .add(Opcode.OP_CHECKSIG)
    .add(Opcode.OP_ELSE)
    .add(Opcode.OP_HASH160)
    .add(H_S)
    .add(Opcode.OP_EQUALVERIFY)
    .add(A_a)
    .add(Opcode.OP_CHECKSIG)
    .add(Opcode.OP_ENDIF);

console.log(test_script)
