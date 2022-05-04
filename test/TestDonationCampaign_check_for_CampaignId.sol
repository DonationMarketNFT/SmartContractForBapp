//Klaytn IDE uses solidity 0.4.24 0.5.6 versions.
pragma solidity >=0.4.24 <=0.5.6;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/DonationCampaign_update.sol";


contract TestDonationCampaign_update_check_for_CampaignIdCheck{
    function testDonationCampaign_update_check_for_CampaignIdCheck() public {

        DonationCampaign_update it = new DonationCampaign_update();

        it.createCampaign("test_campaign", "test_campaign_description", 1000);
  
        uint256[] memory ans = it.CaompaignIdCheck(address(this));
        Assert.equal(ans[0], 0, "value equal test");
    }
}