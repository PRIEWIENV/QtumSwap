<template>
  <div class="demo">
    <!--<h1>{{ msg }}</h1>-->
    <h3>Message</h3>
    <ul>
      <li>
        Sender:
      </li>
      <li>
        <span> {{tx.sender}}</span>
      </li>
    </ul>
    <ul>
      <li>
        BTCHashKey:
      </li>
      <li>
        <span> {{tx.hash}}</span>
      </li>
    </ul>
    <ul>
      <li>
        Receiver:
      </li>
      <li>
        <span> {{tx.recevier}}</span>
      </li>
    </ul>
    <ul>
      <li>
        Amount:
      </li>
      <li>
        <span> {{tx.amount}}</span>
      </li>
      <li>
        <span>Qtum</span>
      </li>
    </ul>
    <br/>
    <button type="submit" @click="verifyTx">Verify Tx</button>
  </div>
</template>

<script>
var {getBalance} = require('@/assets/getbalance')

this.getBalance = getBalance()

module.exports = {
  name: 'Sender',
  data () {
    return {
      msg: 'A simple demo for Qtum && Bitcoin atomic swap.',
      user: {
        Name: 'flyq',
        BtcAddress: '12Mb4fY9dw6mFLCSJD6EsQG27QWikx1YwX',
        BTCKeyHash: '0xc2ea8efdca80864795532fdd6f0c310da2e564ccf3813559d34565d9cb808d18',
        BtcAmount: 10,
        QtumAddress: 'dfa5e33ce6807ea71e45111a48958081dcdb2621',
        QtumAmount: 100
      },
      tx: {}
    }
  },
  created () {
    var href = window.location.toString()
    if (href.split('user=')[1] == 'flyq') {
      this.user = this.$store.state.user[0]
    } else if (href.split('user=')[1] == '5sWind'){
      this.user = this.$store.state.user[1]
    }
    this.tx = this.$store.state.tx
  },
  methods: {
    verifyTx () {
      this.$store.state.tx.state = 2
    }
  }
}

</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
  h1,
  h2 {
    font-weight: normal;
  }
  ul {
    list-style-type: none;
    padding: 0;
  }
  li {
    display: inline-block;
    margin: 0 10px;
  }
  a {
    color: #42b983;
  }
  input {
    width: 18rem;
    height: 2rem;
  }
  select {
    width: 6rem;
    height: 2rem;
  }
  button {
    width: 5rem;
    height: 2rem;
    background-color: cornflowerblue;
    color: white;
    border: none;
    font-size: 1rem;
  }

  .demo {
    display: inherit;
  }
</style>
