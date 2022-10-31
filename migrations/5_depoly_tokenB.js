var TokenB = artifacts.require("./TokenB.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(TokenB, 1000000000, accounts[0]);
};

