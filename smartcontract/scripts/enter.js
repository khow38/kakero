const { ethers } = require("hardhat")

async function enterBetting() {
    const betting = await ethers.getContract("Betting")
    const entranceFee = await betting.getEntranceFee()
    await betting.betting(1,{ value: entranceFee })
    console.log("Entered!")
}

enterBetting()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
