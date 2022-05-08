const main = async () => {
  const [owner, randomPerson] = await hre.ethers.getSigners();
  const honkContractFactory = await hre.ethers.getContractFactory("HonkPortal");
  const honkContract = await honkContractFactory.deploy({
    value: hre.ethers.utils.parseEther("0.1"),
  });
  await honkContract.deployed();

  console.log("Contract deployed to: ", honkContract.address);

  let contractBalance = await hre.ethers.provider.getBalance(
    honkContract.address
  );
  console.log(
    "Contract Balance:",
    hre.ethers.utils.formatEther(contractBalance)
  );

  await honkContract.registerNickname("TACO");
  let nickname = await honkContract.getNickname(owner.address);
  console.log(nickname);

  await honkContract.changeNickname("Taco");
  nickname = await honkContract.getNickname(owner.address);
  console.log(nickname);

  await honkContract.changeNickname("Taco");
  nickname = await honkContract.getNickname(owner.address);
  console.log(nickname);
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
