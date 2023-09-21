module.exports = function(context, options) {
  return {
    name: "symlinks",
    configureWebpack(config, isServer, utils) {
      return {
        resolve: {
          symlinks: false
        }
      };
    }
  };
};