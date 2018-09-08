module.exports = {
  entry: {
    bundle1: __dirname + "/app/bookroom.js",
    bundle2: __dirname + "/app/openlock.js",
    bundle: __dirname + "/app/getbalance.js"
  },
  output: {
    path: __dirname + "/public/js",
    filename: "[name].js"
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        use: {
          loader: "babel-loader"
        },
        exclude: /node_modules/
      },
      {
        test: /\.json$/,
        use: {
          loader: "json-loader"
        },
        exclude: /node_modules/
      }
    ]
  },
  node: {
    fs: "empty",
    net: "empty",
    tls: "empty"
  }
};
