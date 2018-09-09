<template>
  <div id="app">
    <el-container>
      <el-header>
        <div class="header">
          <img id="logo" height="60px" src="./assets/logo.png">
          <div class="userinfo">
            <span>{{user.Name}}</span>&nbsp
            <span>BTC-{{user.BtcAmount}}</span>&nbsp
            <span>Qtum-{{user.QtumAmount}}</span>&nbsp
          </div>
        </div>
      </el-header>
      <el-main>
    <router-view/>
      </el-main>
    </el-container>
  </div>
</template>

<script>
import ElContainer from '../node_modules/element-ui/packages/container/src/main.vue'
import ElHeader from '../node_modules/element-ui/packages/header/src/main.vue'
import ElMain from '../node_modules/element-ui/packages/main/src/main.vue'
import ElAside from '../node_modules/element-ui/packages/aside/src/main.vue'

export default {
  components: {
    ElAside,
    ElMain,
    ElHeader,
    ElContainer},
  name: 'App',
  data () {
    return {
      user: {
        Name: 'flyq',
        BtcAddress: '12Mb4fY9dw6mFLCSJD6EsQG27QWikx1YwX',
        BtcAmount: 10,
        QtumAddress: 'dfa5e33ce6807ea71e45111a48958081dcdb2621',
        QtumAmount: 100
      }
    }
  },
  created () {
    var href = window.location.toString()
    if (href.split('user=')[1] == 'flyq') {
      this.user = this.$store.state.user[0]
    } else if (href.split('user=')[1] == '5sWind'){
      this.user = this.$store.state.user[1]
    }
  }
}
</script>

<style>
  #app {
    font-family: 'Avenir', Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    text-align: center;
    color: #2c3e50;
  }
  .header{
    text-align: left;
    height:60px;
  }
  .userinfo{
    display: inline-block;
    float: right;
    font-size:18px;
    padding-top: 8px;
  }
</style>
