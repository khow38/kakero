const { ethers } = require("hardhat")

const networkConfig = {
    default: {
        name: "hardhat",
        keepersUpdateInterval: "30",
    },
    31337: {
        name: "localhost",
        subscriptionId: "588",
        gasLane: "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc", // 30 gwei
        matchDateTimestamp: "1683493200", // Sunday, May 7, 2023 21:00:00 PM
        gameDescription: "Bet the winner of LOWER FINAL, MSI 2023, Monday, May 8, 2023 6:00:00 AM GMT+09:00",
        option1Name: "PSG",
        option1LeagueName: "PCS",
        option2Name: "GG",
        option2LeagueName: "LCS",
        lottoEntranceFee: ethers.utils.parseEther("0.001"), // 0.001 ETH
        callbackGasLimit: "500000", // 500,000 gas
    },
    11155111: {
        name: "sepolia",
        subscriptionId: "719",
        gasLane: "0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c", // 30 gwei
        matchDateTimestamp: "1683723600",
        gameDescription: "Bet the winner of Bracket Stage, MSI 2023, May 10, 2023 1:00:00 PM GMT",
        option1Name: "MAD Lions",
        option1LeagueName: "LEC",
        option2Name: "T1",
        option2LeagueName: "LCK",
        lottoEntranceFee: ethers.utils.parseEther("0.001"), // 0.001 ETH
        callbackGasLimit: "500000", // 500,000 gas
        vrfCoordinatorV2: "0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625"
    },
    5: {
        name: "goerli",
        subscriptionId: "9237",
        gasLane: "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15", // 150 gwei
        matchDateTimestamp: "1683493200", // Sunday, May 7, 2023 21:00:00 PM
        gameDescription: "Bet the winner of LOWER FINAL, MSI 2023, Monday, May 8, 2023 6:00:00 AM GMT+09:00",
        option1Name: "PSG",
        option1LeagueName: "PCS",
        option2Name: "GG",
        option2LeagueName: "LCS",
        lottoEntranceFee: ethers.utils.parseEther("0.001"), // 0.001 ETH
        callbackGasLimit: "500000", // 500,000 gas
        vrfCoordinatorV2: "0x2ca8e0c643bde4c2e08ab1fa0da3401adad7734d",
    },
    1: {
        name: "mainnet",
        matchDateTimestamp: "1683493200", // Sunday, May 7, 2023 21:00:00 PM
        gameDescription: "Bet the winner of LOWER FINAL, MSI 2023, Monday, May 8, 2023 6:00:00 AM GMT+09:00",
        option1Name: "PSG",
        option1LeagueName: "PCS",
        option2Name: "GG",
        option2LeagueName: "LCS",
        lottoEntranceFee: ethers.utils.parseEther("0.001"), // 0.001 ETH
        callbackGasLimit: "500000", // 500,000 gas
    },
}

const developmentChains = ["hardhat", "localhost"]
const VERIFICATION_BLOCK_CONFIRMATIONS = 6
const frontEndContractsFile = "../nextjs-smartcontract-lottery-fcc/constants/contractAddresses.json"
const frontEndAbiFile = "../nextjs-smartcontract-lottery-fcc/constants/abi.json"

module.exports = {
    networkConfig,
    developmentChains,
    VERIFICATION_BLOCK_CONFIRMATIONS,
    frontEndContractsFile,
    frontEndAbiFile,
}
