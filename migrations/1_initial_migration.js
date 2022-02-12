const Migrations = artifacts.require("./Migrations.sol");
const NFTSimple = artifacts.require("./NFTSimple.sol");
module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(NFTSimple, "Hello, Klaytn");
};
