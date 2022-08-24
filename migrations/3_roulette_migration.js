const Roulette = artifacts.require("Roulette");
const RandomNumber = artifacts.require("RandomNumber");

module.exports = function (deployer) {
  deployer.deploy(Roulette, RandomNumber.address);
};