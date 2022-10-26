let DEX = artifacts.require("./DEX.sol");

module.exports = async function (deployer) {
  let deployExchange = await deployer.deploy(DEX);
};