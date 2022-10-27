var TokenA = artifacts.require("./TokenA.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(TokenA, 1000000000, accounts[0]);
};