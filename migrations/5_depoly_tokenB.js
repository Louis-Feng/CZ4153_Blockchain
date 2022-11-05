var TokenB = artifacts.require("./TokenB.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(TokenB, accounts[0]);
};

