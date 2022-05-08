const main = async () => {
  const [deployer] = await hre.ethers.getSigners();
  const accountBalance = await deployer.getBalance();

  console.log("Deploying contracts with account: ", deployer.address);
  console.log("Account Balance: ", accountBalance.toString());

  const honkContractFactory = await hre.ethers.getContractFactory("HonkPortal");
  const honkContract = await honkContractFactory.deploy({
    value: hre.ethers.utils.parseEther("0.1"),
  });
  await honkContract.deployed();

  console.log("HonkPortal address: ", honkContract.address);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
