<template>
  <div class="demo">
    <!--<h1>{{ msg }}</h1>-->
    <ul>
      <li>
          Sender:
      </li>
      <li>
        <span> {{user.QtumAddress}}</span>
      </li>
    </ul>
    <ul>
      <li>
        BTCHashKey:
      </li>
      <li>
        <span> {{user.BTCKeyHash}}</span>
      </li>
    </ul>
    <ul>
      <li>
          Receiver:
      </li>
      <li>
        <input class="s2" v-model="recevier">
      </li>
    </ul>
    <ul>
      <li>
          Amount:
      </li>
      <li>
        <input class="a1" v-model="txAmount"
        >
      </li>
      <li>
        <span>Qtum</span>
      </li>
    </ul>
    <br/>
    <button type="submit" @click="sendTx">Send Tx</button>
    <button type="submit" @click="toRecevier">To Recevier</button>
    <form v-if="this.$store.state.tx.state==1" v-loading="'loading...'">
    <br/>
    <p v-if="this.$store.state.tx.state==1">Waiting for other's response...</p>
    <p v-if="this.$store.state.tx.state==2">Got Bitcoin!</p>
    <p v-if="this.$store.state.tx.state==2">Tx Successfully.</p>
</form>
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
      recevier: '',
      txAmount: ''
    }
  },
  created () {
    var href = window.location.toString()
    if (href.split('user=')[1] == 'flyq') {
      this.user = this.$store.state.user[0]
    } else if (href.split('user=')[1] == '5sWind'){
      this.user = this.$store.state.user[1]
    }
  },
  methods: {
    sendTx () {
      this.$store.state.tx.sender = this.user.QtumAddress
      this.$store.state.tx.hash = this.user.BTCKeyHash
      this.$store.state.tx.recevier = this.recevier
      this.$store.state.tx.amount = this.txAmount
      this.$store.state.tx.state = 1
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
