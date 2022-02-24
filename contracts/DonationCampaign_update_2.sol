//Klaytn IDE uses solidity 0.4.24 0.5.6 versions.
pragma solidity >=0.4.24 <=0.5.6; 
pragma experimental ABIEncoderV2;

import './KIP17Token.sol';

//bytes32 public empty = keccak256(bytes(""));

contract DonationCampaign_update is KIP17Token('DonationMarket','DM' ){

    struct Campaign {
        address payable campaign_creator_address; // 캠페인 만든 사람의 주소 - 이 주소로 기부금 보내짐  --> 환불 전까지는 스마트 컨트렉트 주소에 저장
        string campaign_name; // 캠페인 이름
        string campaign_description; // 캠페인 내용
        uint256 target_amount; // 목표 모금액
        uint256 current_amount; // 현재 모금액
        bool campaign_state;    // 캠페인 상태(모금중, 모금끝)
        bool campaign_refund_state; // 캠페인 환불 상태 (환불 불가, 환불 가능)
        mapping(address => uint256) campaign_fundingAmountList; // 캠페인에 모금한 사람과 그 funding amount List
    }

    mapping(address => uint256[]) public campaignId; // 캠페인에 고유 숫자 부여. 해당 단체가 올린 캠페인 찾을 수 있음. 
    Campaign[] public campaignList; // 구조체 Campaign을 저장하는 전체 배열 campaign_list
    mapping(uint256 => address[]) public userList;
    mapping(address => uint256[]) public userDonatedList;
    uint public CampaignNumber = 0;
    uint256 contractBalance = 0;

    uint256 tokenId = 0;

    // 캠페인 등록
    event CreatedCampaign(
        string _campaign_name,
        string _campaign_description,
        uint256 _target_amount
    );

    function createCampaign(
        string memory _campaign_name,
        string memory _campaign_description,
        uint256 _target_amount
    ) public {

        //입력받은 캠페인 인스턴스 생성
        Campaign memory newCampaign = Campaign({
            campaign_creator_address: msg.sender,
            campaign_name: _campaign_name,
            campaign_description : _campaign_description,
            target_amount: _target_amount,
            current_amount: 0,
            campaign_state : true,
            campaign_refund_state : false 
        });

        // 새로운 캠페인 아이디 삽입
        campaignId[msg.sender].push(campaignList.length);
        // 배열에 새로운 캠페인를 삽입
        campaignList.push(newCampaign);
        CampaignNumber++;

        // 프론트 이벤트
        emit CreatedCampaign(_campaign_name, _campaign_description,  _target_amount);
    }


    function _sendDonationNFT (
        uint256 tokenId, 
        string memory tokenURI,
        string memory tokenName, 
        string memory tokenDescription, 
        string memory tokenDate,
        string memory tokenNumber
    ) private returns (bool) {
        KIP17MetadataMintable.mintWithTokenURI(msg.sender, tokenId, tokenURI, tokenName, tokenDescription, "", "", tokenDate, tokenNumber);
        return true;
    } // NFT 발행 
    

    // 캠페인 존재여부 확인하는 함수
    function hasCampaign(uint256 _campaignId) private view returns (bool) { //private로 내부 함수에서만 호출 
        if (campaignList.length >= _campaignId) {
            return true;
        }
        return false;
    }

    event DonatedTocampaign(uint256 _campaignId, uint256 _amount);

    function donateTocampaign(uint256 _campaignId, uint256 _amount) public payable {

        // 존재하는 캠페인인지 확인
        require(hasCampaign(_campaignId), "There is no campaign.");
        // 모금이 끝난 캠페인인지 확인
        require(campaignList[_campaignId].campaign_state == true, "Fundraising has ended.");
        // 기부 금액이 0보다 커야함
        require(_amount > 0, "The amount of your donation must be greater than zero.");
        // 기부 금액이 실제 할당한 금액과 같은지
        require(msg.value == _amount, "you value is not equal to amount");
        
        // // 송금  - 
        contractBalance += msg.value;


        // campaignList[_campaignId].campaign_creator_address.transfer(_amount);


        //address _receiver = address(this);

        //address payable receiver = address(uint160(_receiver)); // to address is contract address // solidity issue 
        //receiver.transfer(_amount); // smart contract 주소로 해당 금액 전송 // 보안 이슈 해결법은?  reentrant issue 

        // 3. 유저 리스트에 유저 추가
        bool check = false;
        // 이미 배열에 있는지 확인
        for (uint256 i = 0; i < userList[_campaignId].length; i++) {
            if (userList[_campaignId][i] == msg.sender) {
                check = true;
                break;
            }
        }
        
        if (!check) {
            userList[_campaignId].push(msg.sender); // contract에 기부한 user
            userDonatedList[msg.sender].push(_campaignId);
        }
        
        // 4. 캠페인에 현재 기부금액 업데이트
        campaignList[_campaignId].current_amount += _amount;

        campaignList[_campaignId].campaign_fundingAmountList[msg.sender] += _amount;

            // NFT 발행
        tokenId++;

        require(
        _sendDonationNFT(tokenId, " ", campaignList[_campaignId].campaign_name, campaignList[_campaignId].campaign_description, "2022-02-21", "1")
        ,"Donation NFT: minting failed");
        
        // 프론트 이벤트
        emit DonatedTocampaign(_campaignId, _amount);
    }

    function refundState(uint256 _campaignId) external view returns (bool) {
        return campaignList[_campaignId].campaign_refund_state;
    } // refund 상태 확인 

    function setStateToRefund(uint256 _campaignId) external onlyMinter { // 환불 모드로 변경, 해당 캠페인 정지 -> 접근 권한 제한 필요 onlyMinter로 contract 생성자만 접근 가능 
        campaignList[_campaignId].campaign_refund_state = true;
        campaignList[_campaignId].campaign_state = false;
    }

    event Refunded(uint256 campaignId, address userAddr, uint256 refundAmount);

    function refund(uint256 _campaignId, address _userAddr) external { // 환불 
        require(campaignList[_campaignId].campaign_refund_state == true, "this campaign is not refund state");

        require(campaignList[_campaignId].current_amount != 0, "all funds are returned");

        require(campaignList[_campaignId].campaign_fundingAmountList[_userAddr] != 0, "your funds are refurned");
        
        address msgSender = msg.sender;
        address payable _to = address(uint160(msgSender));

        uint256 refundAmount = campaignList[_campaignId].campaign_fundingAmountList[_userAddr];

        (bool success, ) = _to.call.value(refundAmount)("");  // refund 
        require(success, "Failed to send coin");

        campaignList[_campaignId].campaign_fundingAmountList[_userAddr] = 0;
        campaignList[_campaignId].current_amount -= refundAmount;

        emit Refunded(_campaignId, _userAddr, refundAmount);
    }

    event SearchDonationList(uint256[] result);

    function DonationList() external { // user의 Donation 현황을 조회 
        emit SearchDonationList(userDonatedList[msg.sender]);
    }

    event SearchUserList(address[] result);

    function UserListCheck(uint256 Id) external {
        emit SearchUserList(userList[Id]);
    }

    event SearchGegGampaignNumber(uint256 result);

    function GetCampaignNumber() external{
        emit SearchGegGampaignNumber(CampaignNumber);
    } // 생성된 총 Campaign Number 리턴 받기 


    event SearchCampaignInformation(address , string, string, uint256, uint256 );

    function CampaignInformation(uint256 CampaignNumber) external {
        emit SearchCampaignInformation(campaignList[CampaignNumber].campaign_creator_address, 
        campaignList[CampaignNumber].campaign_name,
        campaignList[CampaignNumber].campaign_description,
        campaignList[CampaignNumber].target_amount,
        campaignList[CampaignNumber].current_amount 
        );
    } // Campaign 관련 정보 가져오기 
}