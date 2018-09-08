var bitcoin = require('bitcoinjs-lib')
var ops = bitcoin.opcodes;
var network = bitcoin.networks.testnet;

console.log(network);
console.log(ops.OP_CHECKLOCKTIMEVERIFY);
// deterministic RNG for testing only
function rng () { return new Buffer.from('zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz')  }

const keyPair = bitcoin.ECPair.makeRandom({rng:rng, network:network})
const { address  } = bitcoin.payments.p2pkh({ pubkey: keyPair.publicKey  })
var privateKey = keyPair.toWIF();

let account;
account = new bitcoin.ECPair.fromWIF(privateKey, network);
account.__proto__.getPublicKey = () => account.getPublicKeyBuffer().toString('hex');
account.__proto__.getPrivateKey = () => privateKey;

console.log(keyPair);
console.log(typeof(keyPair));
console.log(keyPair.publicKey);
console.log(keyPair.privateKey);
console.log(address);
console.log('account:')
console.log(account);
////console.log(account.getAddress());
//console.log(account.getPublicKey());

//var pubKey = keyPair.getPublicKeyBuffer();
//var pubKeyHash = bitcoin.crypto.hash160(pubKey);

const fromHexString = hexString =>
  new Uint8Array(hexString.match(/.{1,2}/g).map(byte => parseInt(byte, 16)))

const hash = (secret) => {
    return bitcoin.crypto.sha256(fromHexString(secret))
}

const secretHash = hash('74657374'); //
console.log(secretHash);


const BTCscript = bitcoin.script.compile([

    ops.OP_RIPEMD160,
    Buffer.from(secretHash, 'hex'),
    ops.OP_EQUALVERIFY,

    Buffer.from(recipientPublicKey, 'hex'),
    ops.OP_EQUAL,
    ops.OP_IF,

    Buffer.from(recipientPublicKey, 'hex'),
    ops.OP_CHECKSIG,

    ops.OP_ELSE,

    bitcoin.script.number.encode(lockTime),
    ops.OP_CHECKLOCKTIMEVERIFY,
    ops.OP_DROP,
    Buffer.from(ownerPublicKey, 'hex'),
    ops.OP_CHECKSIG,

    ops.OP_ENDIF,

])
