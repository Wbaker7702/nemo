// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const { generateWebpackConfig } = require('shakapacker')

const webpackConfig = generateWebpackConfig()

// Webpack 5 no longer auto-polyfills Node core modules in browser bundles.
webpackConfig.resolve = webpackConfig.resolve || {}
webpackConfig.resolve.fallback = {
  ...(webpackConfig.resolve.fallback || {}),
  dgram: false,
  fs: false,
  net: false,
  tls: false,
  child_process: false
}

// Exclude test files from production builds
if (process.env.NODE_ENV === 'production') {
  webpackConfig.module.rules.push({
    test: /\.(test|spec)\.(js|jsx)$/,
    exclude: /node_modules/,
    use: 'ignore-loader'
  })
}

module.exports = webpackConfig
