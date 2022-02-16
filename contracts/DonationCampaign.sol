pragma solidity ^0.8.0;

//bytes32 public empty = keccak256(bytes(""));

contract DonationCampaign {

    struct Campaign {
        address campaign_creator_address; // 캠페인 만든 사람의 주소 - 이 주소로 기부금 보내짐  
        string campaign_name; // 캠페인 이름
        uint256 target_amount; // 목표 모금액
        uint256 current_amount; // 현재 모금액
        bool campaign_state;    // 캠페인 상태(모금중, 모금끝)
    }

    struct Donator{
        address donator_address; // 기부자 주소
        uint256 donate_amount;    // 기부 금액
    }

    mapping(address => uint256[]) public campaignId; // 캠페인에 고유 숫자 부여. 해당 단체가 올린 캠페인 찾을 수 있음. 
    Campaign[] public campaignList; // 구조체 Campaign을 저장하는 전체 배열 campaign_list
    mapping(uint256 => address[]) public userList;
    mapping(address => uint256[]) public userDonatedList;

    // 캠페인 등록
    event CreatedCampaign(
        string _campaign_name,
        uint256 _target_amount
    );

    function createCampaign(
        string memory _campaign_name,   
        uint256 _target_amount
    ) public {
        // 입력받은 캠페인 인스턴스 생성
        Campaign memory newCampaign = Campaign({
            campaign_creator_address: msg.sender,
            campaign_name: _campaign_name,
            target_amount: _target_amount,
            current_amount: 0,
            campaign_state : true
        });

        // 새로운 캠페인 아이디 삽입
        campaignId[msg.sender].push(campaignList.length);
        // 배열에 새로운 캠페인를 삽입
        campaignList.push(newCampaign);
        // 프론트 이벤트
        emit CreatedCampaign(_campaign_name, _target_amount);
    }

    // 캠페인 존재여부 확인하는 함수
    function hasCampaign(uint256 _campaignId) public view returns (bool) {
        if (campaignList.length >= _campaignId) {
            return true;
        }
        return false;
    }


    event DonatedTocampaign(uint256 _campaignId, uint256 _amount);

    function donateTocampaign(uint256 _campaignId, uint256 _amount) public {
        // 존재하는 캠페인인지 확인
        require(hasCampaign(_campaignId), " ");
        // 모금이 끝난 캠페인인지 확인
        require(campaignList[_campaignId].campaign_state == true, " ");
        // 기부 금액이 0보다 커야함
        require(_amount > 0, "");
        
        // 기부자가 가지고있는 klay 보다 큰지 확인
        // require(
        //     _amount <= klay.balanceOf(msg.sender),
        //     ""
        // );
        
        // 1. klay받기
        //klay.transferFrom(msg.sender, address(this), _amount);
        
        // 2. 캠페인에 기부한 유저 정보 저장
        // userInfo[msg.sender][_campaignId].donateAmount = userInfo[msg.sender][
        //     _campaignId
        // ].donateAmount.add(_amount);
        
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
            userList[_campaignId].push(msg.sender);
            userDonatedList[msg.sender].push(_campaignId);
        }
        
        // 4. 캠페인에 현재 기부금액 업데이트
        campaignList[_campaignId].current_amount += _amount;
        
        // 프론트 이벤트
        emit DonatedTocampaign(_campaignId, _amount);
    }

}