const config = {
  // Hardhat local network
  // Mock Data (it won't work)
  31337: {
    name: "hardhat",
    keyHash:
      "0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4",
    fee: "0.1",
    fundAmount: "10000000000000000000",
  },
  // Ethereum Mainnet
  1: {
    name: "mainnet",
    linkToken: "0x514910771AF9Ca656af840dff83E8264EcF986CA",
    vrfCoordinator: "0xf0d54349aDdcf704F77AE15b96510dEA15cb7952",
    keyHash:
      "0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445",
    fee: "2",
  },
  // Goerli
  5: {
    name: "goerli",
    linkToken: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
    vrfCoordinator: "0x2bce784e69d2Ff36c71edcB9F88358dB0DfB55b4",
    keyHash:
      "0x0476f9a745b61ea5c0ab224d3a6e4c99f0b02fce4da01143a4f70aa80ae76e8a",
    fee: "0.1",
    fundAmount: "2000000000000000000",
  },
};

const autoFundCheck = async (
  contractAddr,
  networkName,
  linkTokenAddress,
  additionalMessage
) => {
  const chainId = await getChainId();
  console.log("Checking to see if contract can be auto-funded with LINK:");
  const amount = config[chainId].fundAmount;
  // check to see if user has enough LINK
  const accounts = await ethers.getSigners();
  const signer = accounts[0];
  const LinkToken = await ethers.getContractFactory("LinkToken");
  const linkTokenContract = new ethers.Contract(
    linkTokenAddress,
    LinkToken.interface,
    signer
  );
  const balanceHex = await linkTokenContract.balanceOf(signer.address);
  const balance = await ethers.BigNumber.from(balanceHex._hex).toString();
  const contractBalanceHex = await linkTokenContract.balanceOf(contractAddr);
  const contractBalance = await ethers.BigNumber.from(
    contractBalanceHex._hex
  ).toString();
  if (balance > amount && amount > 0 && contractBalance < amount) {
    // user has enough LINK to auto-fund
    // and the contract isn't already funded
    return true;
  } else {
    // user doesn't have enough LINK, print a warning
    console.log(
      "Account doesn't have enough LINK to fund contracts, or you're deploying to a network where auto funding isnt' done by default"
    );
    console.log(
      "Please obtain LINK via the faucet at https://" +
        networkName +
        ".chain.link/, then run the following command to fund contract with LINK:"
    );
    console.log(
      "npx hardhat fund-link --contract " +
        contractAddr +
        " --network " +
        networkName +
        additionalMessage
    );
    return false;
  }
};

module.exports = {
  config,
  autoFundCheck,
};
