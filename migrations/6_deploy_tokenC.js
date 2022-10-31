var TokenC = artifacts.require("./TokenC.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(TokenC, 10000000, accounts[0]);
};