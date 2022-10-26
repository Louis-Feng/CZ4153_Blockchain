var BasicToken = artifacts.require("BasicToken");
var TokenA = artifacts.require("TokenA");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(BasicToken, 10000, accounts[0]);
  deployer.deploy(TokenA, 10000, accounts[1]);
};