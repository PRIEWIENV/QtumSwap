const bitcoin = require("bitcoinjs-lib");

function setAddress (address) {
  this.address = address;
}

function getAddress () {
  const keyPair = bitcoin.ECPair.fromWIF(cTB14gEhBznkica1ucJQtLjrPNcKi7AbzugFhY4zvEF26SvXRKMc);
  const { address } = bitcoin.payments.p2pkh({ pubkey: keyPair.publicKey });
  return { address: address };
}

module.exports = {
  getAddress: getAddress
};

