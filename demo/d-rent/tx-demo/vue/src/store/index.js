import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

const state = {
  user: [
    {
      Name: 'flyq',
      BtcAddress: '12Mb4fY9dw6mFLCSJD6EsQG27QWikx1YwX',
      BTCKeyHash: '0xc2ea8efdca80864795532fdd6f0c310da2e564ccf3813559d34565d9cb808d18',
      BtcAmount: 10,
      QtumAddress: 'dfa5e33ce6807ea71e45111a48958081dcdb2621',
      QtumAmount: 100
    },
    {
      Name: '5sWind',
      BtcAddress: 'M21b4789dwFm6LCDJS6sEA72GQWiXwY1xk',
      BTCKeyHash: '0xc2ea8efdca80864795532fdd6f0c310da2e564ccf3813559d34565d9cb808d18',
      BtcAmount: 10,
      QtumAddress: 'eb8929ae84dcca32cdd6745d4687acb302fe4b2a',
      QtumAmount: 100
    }
  ],
  tx: {
    sender: '',
    hash: '',
    recevier: '',
    amount: 0,
    state: 0
  }
}

export default new Vuex.Store({
  state
})
