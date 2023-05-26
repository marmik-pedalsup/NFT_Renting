require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config({path: ".env"});
// require("@nomiclabs/hardhat-waffle");

const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const POLYSCAN_API_KEY = process.env.POLYSCAN_API_KEY;

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.1",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          },
        }
      },
    ]
  },
  networks:{
    mumbai:{
      url: ALCHEMY_API_KEY,
      accounts:[PRIVATE_KEY],
    },
  },
  etherscan:{
    apiKey:{
      polygonMumbai: POLYSCAN_API_KEY,
    },
  },
  // allowUnlimitedContractSize: true, 24KB > contract size

};