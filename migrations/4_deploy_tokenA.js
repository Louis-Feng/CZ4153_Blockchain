var TokenA = artifacts.require("./TokenA.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(TokenA, 10000000, accounts[0]);
};