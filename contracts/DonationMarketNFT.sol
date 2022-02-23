//Klaytn IDE uses solidity 0.4.24 0.5.6 versions.
pragma solidity >=0.4.24 <=0.5.6; 

contract DonationMarket {
    string public name = "DonationMarket";
    string public symbol = "DM";

    mapping(uint256 => address) public tokenOwner;  
    mapping(uint256 => string) public tokenURIs;  
/*
    struct Campaign { // Campaign 생성 시, 관련 정보를 받아서 해당 구조체에서 관리 
        string campaignName; // Campaign Name
        string campaignDescription; // Campaign Information 
        string campaignCreaterName; // Campaign 생성자 혹은 단체 이름
        string campaignAgencyURL; // Campaign 단체 홈페이지 주소
        address campaignAgencyAddress; // 모금 조건 완료 후 전송될 주소
        uint256 campaignTargetAmount; // 모금 목표 금액
        uint256 campaignTargetTiem; // 모금 목표 시간
        bool campaignStatus;// 모금 상태 관리 (모금 중, 모금 종료)
    }

    struct Donator{
        address donator_address; // 기부자 주소
        uint256 donate_amount; // 기부 금액
    }
*/
    // 필요 함수 목록

    // 1. Mint 기능
    //  ㄴ 조건부 모금
    //      ㄴ 시간 제한 모금
    //      ㄴ 금액 제한 모금

    //  ㄴ 제한 없는 모금 
    // 소유한 토큰 리스트
    
    mapping(address => uint256[]) private _ownedTokens;
    // onKIP17Received bytes value

    bytes4 private constant _KIP17_RECEIVED = 0x6745782b;

    // mint(tokenId, uri, owner) : 발행
    // transferFrom(from, to, tokenId) : 전송 -> owner가 바뀌는 것 (from -> to)

    function mintWithTokenURI(address to, uint256 tokenId, string memory tokenURI) public returns(bool){
        // to에게 tokenId(일련번호)를 발행하겠다. 
        // 적힐 글자는 tokenURI
        tokenOwner[tokenId] = to;
        tokenURIs[tokenId] = tokenURI;

        // add token to the list
        _ownedTokens[to].push(tokenId);

        return true;
    }

    function balanceOf(address owner) public view returns (uint256) {
    require(
        owner != address(0),
        "KIP17: balance query for the zero address"
    );
    return _ownedTokens[owner].length;
}

 function balance (address _addr) public view returns(uint){
          return balanceOf(_addr);
      }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public{
        require(from == msg.sender, "from !- msg.sender"); // 보내는 사람이 현재 이 함수를 실행한 주체 
        require(from == tokenOwner[tokenId], "you are not the owner of the token"); // 보내는 사람이 보내려고 하는 토큰의 주인
        //
        _removeTokenFromList(from, tokenId);
        _ownedTokens[to].push(tokenId);
        //
        tokenOwner[tokenId] = to;

        // 만약에 받는 쪽이 실행할 코드가 있는 스마트 컨트렉트이면 코드를 실행할 것
        require(
            _checkOnKIP17Received(from, to, tokenId, _data), "KIP17: transfer to non KIP17Receiver implement"
        );

        
    }

    //internal option : 외부 호춣 불가 
    function _checkOnKIP17Received(address from, address to, uint256 tokenId, bytes memory _data) internal returns(bool){
        bool success;
        bytes memory returndata;

        if(!isContract(to)){ // smart contract address인지 판별
            return true;
        }

        (success, returndata) = to.call( // 성공여부와 return 값을 받아와라 
            abi.encodeWithSelector(
                _KIP17_RECEIVED, //smart contract면 이걸 실행해라
                msg.sender,
                from,
                tokenId,
                _data
            )
        );
        if(
            returndata.length != 0 && //만약 return 값이 존재하며 그 값이 _KIP17_RECEIVED이면, 
            abi.decode(returndata, (bytes4)) == _KIP17_RECEIVED
        ) {
            return true;
        }
        return false;
    }

    function isContract(address account) internal view returns(bool){
        uint256 size;
        assembly {size := extcodesize(account)}
        return size > 0;
    }

    function _removeTokenFromList(address from, uint256 tokenId) private{
        // [10, 15, 19, 20] -> 19번을 삭제하고 싶어요.
        // [10, 15, 20, 19]
        // [10, 15, 20]
        uint256 lastTokenIdx = _ownedTokens[from].length - 1;
        for(uint256 i = 0; i < _ownedTokens[from].length; i++){
            if(tokenId == _ownedTokens[from][i]){
                // swap last token with deleting token;
               _ownedTokens[from][i] = _ownedTokens[from][lastTokenIdx];
               _ownedTokens[from][lastTokenIdx] = tokenId;
                break;
            }
        }
        _ownedTokens[from].length--;
    }

    function ownedTokens(address owner) public view returns (uint256[] memory){
        return _ownedTokens[owner];
    }

    function setTokenUri(uint256 id, string memory uri) public { // memory는 좀 긴 타입의 데이터를 표시할 떄 쓴다. 
        tokenURIs[id] = uri; // mapping
    }
}