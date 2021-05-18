/* eslint-env node */

const path = require('path')

module.exports = {
  mode: process.env.NODE_ENV,
  target: 'web',
  entry: './browser.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js',
    library: {
      name: 'fountainer',
      type: 'umd',
      export: 'default'
    }
  },
  module: {
    rules: [
      {
        test: /\.txt$/,
        use: 'raw-loader'
      },
      {
        test: /\.css$/i,
        use: ['style-loader', 'css-loader']
      },
      {
        test: /\.pegjs$/,
        use: [
          {
            loader: path.resolve(__dirname, 'pegjs-loader.js'),
            options: {
              transpile: {
                presets: ['@babel/env']
              }
            }
          }
        ]
      }
    ]
  },
  devServer: {
    contentBase: path.resolve(__dirname),
    index: 'index.html',
    hot: true,
    compress: true,
    port: 9000
  }
}
