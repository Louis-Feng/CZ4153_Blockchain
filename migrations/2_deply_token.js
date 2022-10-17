var BasicToken = artifacts.require("./BasicToken.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(BasicToken, 10000, accounts[0]);
};