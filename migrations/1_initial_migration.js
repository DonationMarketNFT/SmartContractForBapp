// const Migrations = artifacts.require("./Migrations.sol");
// const NFTSimple = artifacts.require("./NFTSimple.sol");
// const KTP17Token = artifacts.require("./KIP17Token.sol");
const DonationCampaignUpate = artifacts.require(
  "./DonationCampaign_update.sol"
);
module.exports = function (deployer) {
  // deployer.deploy(KTP17Token);
  deployer.deploy(DonationCampaignUpate, "Hello, Klaytn", {
    gas: 40000000000000,
  });
};
