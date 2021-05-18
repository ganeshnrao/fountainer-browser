/* eslint-env node */

const peg = require('pegjs')

module.exports = function (source) {
  return peg.generate(source, {
    format: 'commonjs',
    optimize: 'speed',
    output: 'source'
  })
}
