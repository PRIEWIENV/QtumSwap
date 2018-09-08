<template>
  <div class="demo">
    <h1>{{ msg }}</h1>
    <ul>
      <li>
          Sender:
      </li>
      <li>
        <input class="s1"
        >
          balance:
      </li>
    </ul>
    <ul>
      <li>
          Receiver:
      </li>
      <li>
        <input class="s2"
        >
          balance:
      </li>
    </ul>
    <ul>
      <li>
          Amount:
      </li>
      <li>
        <input class="a1"
        >
      </li>
      <li>
        <select
        >
        <option value="bitcoin">bitcoin</option>
        <option value="qtum">qtum</option>
        <option value="erc20">ERC20</option>
        <option value="erc721">ERC721</option>
        </select>
      </li>
    </ul>
    <br>
    <form v-loading="'loading...'">
    <button type="submit" class="button is-primary is-fullwidth">Send Tx</button>
    <br>
    <p>Waiting for other's response...</p>
    <p>Got Bitcoin!</p>
    <p>Tx Successfully.</p>
</form>
  </div>
</template>

<script>

export default {
  name: "QtumSwap",
  data() {
    return {
      msg: "A simple demo for Qtum && Bitcoin && NFT atomic swap."
    };
  }
};

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

