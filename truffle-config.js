// truffle-config.js
module.exports = {
  networks: {
    klaytn: {
      host: "127.0.0.1",
      port: 7545,
      //from: "0x75a59b94889a05c03c66c3c84e9d2f8308ca4abd", // 계정 주소를 입력하세요
      network_id: "5777", // Baobab 네트워크 id
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
