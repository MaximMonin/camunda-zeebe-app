const { environment } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')
const vue = require('./loaders/vue')

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.prepend('vue', vue)
environment.config.resolve.alias = { 'vue$': 'vue/dist/vue.esm.js' }; 

const notServerRendering = name => name !== 'server_rendering';
environment.splitChunks((config) => Object.assign({}, config, { 
  optimization: {
    splitChunks: {
      chunks: 'all',
      name: true,
      chunks(chunk) {
          return notServerRendering(chunk.name);
      },
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          name: 'vendor',
        },
      },
    },
    runtimeChunk: false,
  }
}))

module.exports = environment
