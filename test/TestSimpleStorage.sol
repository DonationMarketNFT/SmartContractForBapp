//Klaytn IDE uses solidity 0.4.24 0.5.6 versions.
pragma solidity >=0.4.24 <=0.5.6;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/NFTSimple.sol";

contract TestSimpleStorage{
    function testSimpleStorage() public {

        NFTSimple it = new NFTSimple();

        it.mintWithTokenURI(address(this), 20, "happy");
        uint256 ans = it.balanceOf(address(this));
        Assert.equal(ans, 1, "value equal test");
    }
}