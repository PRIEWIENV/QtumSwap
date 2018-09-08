module.exports = {
  entry: {
    bundle1: __dirname + "/app/bookroom.js",
    bundle2: __dirname + "/app/openlock.js",
    bundle: __dirname + "/app/getbalance.js"
  },
  output: {
    path: __dirname + "/public/js",
    filename: "[name].js"
  }
};