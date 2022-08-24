const RandomNumber = artifacts.require("RandomNumber");

var subId = 000;

module.exports = function (deployer) {
  deployer.deploy(RandomNumber, subId);
};