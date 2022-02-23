//Klaytn IDE uses solidity 0.4.24 0.5.6 versions.
pragma solidity >=0.4.24 <=0.5.6;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/DonationCampaign_update.sol";


contract TestDonationCampaign_update{
    function testDonationCampaign_update() public {

        DonationCampaign_update it = new DonationCampaign_update();

        it.createCampaign("test_campaign", "test_campaign_description", "test_campaign_owner", "test_campaign_url", 1000);
        it.donateTocampaign(0, 1);
        
        it.createCampaign("test_campaign", "test_campaign_description", "test_campaign_owner", "test_campaign_url", 1000);
        it.donateTocampaign(1, 1);

        it.createCampaign("test_campaign", "test_campaign_description", "test_campaign_owner", "test_campaign_url", 1000);
        it.donateTocampaign(2, 1);

        uint256[] memory ans = it.DonationList(); 
        Assert.equal(ans[0], 0, "value equal test");
        Assert.equal(ans[1], 1, "value equal test");
        Assert.equal(ans[2], 2, "value equal test");
    }
}

