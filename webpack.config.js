// const HtmlWebpackPlugin = require("html-webpack-plugin");
const path = require("path");

module.exports = {
  mode: "development",
  entry: "./index.js",
  output: {
    path: path.resolve(__dirname, "dist"),
    filename: "bundle.js",
    library: {
      name: "foobar",
      type: "umd",
      export: "default",
    },
  },
  module: {
    rules: [
      {
        test: /\.txt$/,
        use: "raw-loader",
      },
      {
        test: /\.css$/i,
        use: ["style-loader", "css-loader"],
      },
      {
        test: /\.pegjs$/,
        loader: "pegjs-loader",
      },
    ],
  },
  devServer: {
    contentBase: path.resolve(__dirname),
    index: "index.html",
    hot: true,
    compress: true,
    port: 9000,
  },
};
