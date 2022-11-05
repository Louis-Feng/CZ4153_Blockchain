var DEX = artifacts.require("./DEX.sol");

module.exports = function(deployer) {
    deployer.deploy(DEX);
}