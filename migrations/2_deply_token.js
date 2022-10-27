var BasicToken = artifacts.require("./BasicToken.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(BasicToken, 1000000000, accounts[0]);
};