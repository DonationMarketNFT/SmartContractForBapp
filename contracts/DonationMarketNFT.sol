//Klaytn IDE uses solidity 0.4.24 0.5.6 versions.
pragma solidity >=0.4.24 <=0.5.6;

contract DonationMarket {
    string public name = "DonationMarket";
    string public symbol = "DM";

    mapping(uint256 => address) public tokenOwner;  
    mapping(uint256 => string) public tokenURIs;  

    // 필요 함수 목록

    // 1. Mint 기능
    //  ㄴ 조건부 모금
    //      ㄴ 시간 제한 모금
    //      ㄴ 금액 제한 모금

    //  ㄴ 제한 없는 모금 
    
}