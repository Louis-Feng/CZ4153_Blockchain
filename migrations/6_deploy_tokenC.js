var TokenC = artifacts.require("./TokenC.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(TokenC, accounts[0]);
};