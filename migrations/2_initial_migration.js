var Migrations = artifacts.require("./Adoption.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
};
