# Smart Contract 개발 환경 구축

### Truffle : Solidity 개발 환경 - 배포, 테스트 등등

</br>

### Ganache : Ethereum Blockchain Local 환경

</br>
</br>

### git repository clone 후 아래 명령어 입력

</br>

```shell
$ npm install
$ cd node_modules/truffle
$ npm install solc@0.5.6
$ cd -
$ ln -s node_modules/truffle/build/cli.bundled.js truffle
$ export PATH=`pwd`:$PATH
```

위와 같이 하시면 Truffle 환경은 구성이 끝나게 됩니다.

Truffle로 바로 BaoBob 이나 cypress server로 배포할 수 있지만, 우선 저희는 SmartContract를 Test하고 검증해야 하기 때문에 Ganache를 이용하여 로컬 환경에서 배포하도록 하겠습니다.

### Truffle과 Ganache 연동

</br>

아래 링크에서 Ganache를 설치하고 실행합니다.

https://trufflesuite.com/ganache/

Ganache를 실행하면 아래와 같은 Network ID와 RPC Server 정보가 있습니다.

<img width="1209" alt="Screen Shot 2022-02-11 at 3 49 54 PM" src="https://user-images.githubusercontent.com/41497254/153548362-3556c5e3-169f-427a-83a3-940f785f3a3d.png">

보시면 Network ID는 1337이고 RPC Server는 HTTP://127.0.0.1 Port는 7545 입니다.<br/>
혹시 위와 설정이 다르다면, 가장 오른쪽 톱니바퀴를 누르시고 아래 화면에서 변경해주세요.

<img width="1200" alt="Screen Shot 2022-02-11 at 3 52 02 PM" src="https://user-images.githubusercontent.com/41497254/153548584-ba80eb45-e585-4dd5-ba65-9bb04a7cd69e.png">

<br/>

위와 같이 설정 후에 truffle-config.js를 아래와 같이 변경해줍니다.

```javascript
// truffle-config.js
module.exports = {
  networks: {
    klaytn: {
      host: "127.0.0.1", // rpc 주소
      port: 7545, // port name
      //from: "0x75a59b94889a05c03c66c3c84e9d2f8308ca4abd", // 현재는 테스트이기 때문에 필요없지만 추후 배포시에는 account 주소 입력 필요
      network_id: "1337", // 로컬 네트워크 id -> 추후에 메인넷으로 변경 후 배포
      //gas: 20000000, // 트랜잭션 가스 한도
      //gasPrice: 25000000000, // Baobab의 gasPrice는 25 Gpeb입니다
    },
  },
  compilers: {
    solc: {
      version: "0.5.6", // 컴파일러 버전을 0.5.6로 지정
    },
  },
};
```

### Smart Contract 배포하기

우선 배포하고자 하는 Smart Contract를 contracts 폴더 내에 작성합니다. <br/>
그 이후에 migrations/1_initial_migraion.js에서 아래와 같이 작성해줍니다.

```javascript
const Migrations = artifacts.require("./Migrations.sol");
const KlaytnGreeter = artifacts.require("./KlaytnGreeter.sol"); // 작성한 smart contract
module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(KlaytnGreeter, "Hello, Klaytn"); // 이와 같이 작성해주자
};
```

위와 같이 하나의 migration js file에 넣어도 되고, 혹은 migrations 폴더 내에 prefix 숫자를 넣어서 2_klaytn_greeter.js 와 같이 폴더를 생성하여 별도로 배포 코드를 작성해도 된다.

 <br/>

배포 전의 Ganache를 살펴보면 아래와 같다.

 <img width="1197" alt="Screen Shot 2022-02-11 at 4 01 22 PM" src="https://user-images.githubusercontent.com/41497254/153549528-eb5d3369-feab-4c9c-b871-addd8c6af41e.png">

총 10개의 지갑이 있고 각각 100이더씩 있는 것을 볼 수 있다.

 <img width="1199" alt="Screen Shot 2022-02-11 at 4 02 11 PM" src="https://user-images.githubusercontent.com/41497254/153549611-d193d54c-3db4-477b-95a0-c867f3d85ea9.png">

<img width="1210" alt="Screen Shot 2022-02-11 at 4 02 26 PM" src="https://user-images.githubusercontent.com/41497254/153549644-5f556bea-86b1-4541-966d-637ed29ea429.png">

위와 같이 블록도 0개이고 Transaction도 없다

<br/>

이제 terminal에 아래와 같이 명령어를 넣자

```javascript
truffle migrate --network klaytn// klaytn은 truffle-config.js에서 설정한 network name이다.
```

```shell
 ⚡ ⚙ root@gimdaun-ui-MacBook-Pro  ~/klaytn   main ●  truffle migrate --network klaytn

Compiling your contracts...
===========================
> Everything is up to date, there is nothing to compile.


Starting migrations...
======================
> Network name:    'klaytn'
> Network id:      1337
> Block gas limit: 0x6691b7


1_initial_migration.js
======================

   Replacing 'Migrations'
   ----------------------
   > transaction hash:    0x06b66a084e478939099f01725186bb065e12e56415fe2f4a49d6df47506b199c
   > Blocks: 0            Seconds: 0
   > contract address:    0x6133DA5EB2d6Fb4CBb208D7788491212651BbBa6
   > block number:        1
   > block timestamp:     1644563019
   > account:             0x111CF6AD702092D6D6103F8d18f41006A869A335
   > balance:             99.99619978
   > gas used:            190011
   > gas price:           20 gwei
   > value sent:          0 ETH
   > total cost:          0.00380022 ETH


   Replacing 'KlaytnGreeter'
   -------------------------
   > transaction hash:    0xad84658fe1919822cac7b5c270bfefca8a5d376a8aa5f7941e7be070cd670f21
   > Blocks: 0            Seconds: 0
   > contract address:    0x4FB897FFe54D903ccBd2DE14765A948Bca5235Df
   > block number:        2
   > block timestamp:     1644563019
   > account:             0x111CF6AD702092D6D6103F8d18f41006A869A335
   > balance:             99.9917825
   > gas used:            220864
   > gas price:           20 gwei
   > value sent:          0 ETH
   > total cost:          0.00441728 ETH


   > Saving migration to chain.
   > Saving artifacts
   -------------------------------------
   > Total cost:           0.0082175 ETH


Summary
=======
> Total deployments:   2
> Final cost:          0.0082175 ETH
```

위와 같이 log가 나오면서 로컬 환경에 배포가 됨을 알 수 있다.

이제 Ganache에 가서 확인해보면

<img width="1198" alt="Screen Shot 2022-02-11 at 4 06 13 PM" src="https://user-images.githubusercontent.com/41497254/153550219-269951a6-188b-4dd5-b789-1ede176ac673.png">
<img width="1200" alt="Screen Shot 2022-02-11 at 4 06 30 PM" src="https://user-images.githubusercontent.com/41497254/153550254-384b1424-497f-43fa-83d3-e8546326b41a.png">
<img width="1208" alt="Screen Shot 2022-02-11 at 4 06 46 PM" src="https://user-images.githubusercontent.com/41497254/153550287-301009b1-860b-471b-9bd1-d301b0d05a21.png">

위와 같이 smart contract 배포로 인해 Gas가 사용되어 이더가 소모된 부분과 블록이 쌓인 부분, transaction이 발생한 부분을 모니터링 할 수 있다.

smart contract의 동작만을 검증하기 때문에 이더리움 로컬 네트워크 상에서 진행해도 문제 없을 것을 판단된다.
