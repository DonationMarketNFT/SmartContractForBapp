require("dotenv").config();

const HDWalletProvider = require("truffle-hdwallet-provider-klaytn");
const CHAIN_ID = "1001";
const Caver = require("caver-js");

const accessKeyId = "KASK11YDNERYLWWB6NXW3RA7";
const secretAccessKey = "MoLYO0lhmp4xQAPLyz9CL6zVABZ30vVB1Xu2XYxU";
const privateKey =
  "0x896c7849a73a562c52cff3d0822ff33e67fd2c83cb35d6e1c8181cf8baf6e7fd"; // Enter your private key;

var mnemonic =
  "mountains supernatural bird happy sad cool sun moon vehicle soccer can hip";

// truffle-config.js
module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*", // Match any network id
    },
    kasBaobab: {
      provider: () => {
        const option = {
          headers: [
            {
              name: "Authorization",
              value:
                "Basic " +
                Buffer.from(accessKeyId + ":" + secretAccessKey).toString(
                  "base64"
                ),
            },
            { name: "x-chain-id", value: "1001" },
          ],
          keepAlive: false,
        };
        return new HDWalletProvider(
          privateKey,
          new Caver.providers.HttpProvider(
            "https://node-api.klaytnapi.com/v1/klaytn",
            option
          )
        );
      },
      network_id: "1001", //Klaytn baobab testnet's network id
      gas: "8500000",
      gasPrice: "25000000000",
    },
    kasCypress: {
      provider: () => {
        const option = {
          headers: [
            {
              name: "Authorization",
              value:
                "Basic " +
                Buffer.from(accessKeyId + ":" + secretAccessKey).toString(
                  "base64"
                ),
            },
            { name: "x-chain-id", value: "8127" },
          ],
          keepAlive: false,
        };
        return new HDWalletProvider(
          privateKey,
          new Caver.providers.HttpProvider(
            "https://node-api.klaytnapi.com/v1/klaytn",
            option
          )
        );
      },
      network_id: "8217", //Klaytn mainnet's network id
      gas: "8500000",
      gasPrice: "25000000000",
    },
    klaytn: {
      host: "127.0.0.1",
      port: 7545,
      //from: "0x75a59b94889a05c03c66c3c84e9d2f8308ca4abd", // 계정 주소를 입력하세요
      network_id: "5777", // Baobab 네트워크 id
      gas: 6000000, // 트랜잭션 가스 한도
      //gasPrice: 25000000000, // Baobab의 gasPrice는 25 Gpeb입니다
    },
  },
  compilers: {
    solc: {
      version: "0.5.6", // 컴파일러 버전을 0.5.6로 지정
      settings: {
        optimizer: {
          enabled: true, // Default: false
          runs: 1000, // Default: 200
        },
      },
    },
  },
  plugins: ["truffle-contract-size"],
};
