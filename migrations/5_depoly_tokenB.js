var TokenB = artifacts.require("./TokenB.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(TokenB, 10000000, accounts[0]);
};

