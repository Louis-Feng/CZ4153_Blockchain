var TokenA = artifacts.require("./TokenA.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(TokenA, accounts[0]);
};