// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const AnyMoeNFT = await hre.ethers.getContractFactory("AnyMoeNFT");
  const AnyMoeAuction = await hre.ethers.getContractFactory("AnyMoeAuction");
  const AnyMoeCreator = await hre.ethers.getContractFactory("AnyMoeCreator");

  const anymoecreator = await AnyMoeCreator.deploy(3, 30);

  await anymoecreator.deployed();

  console.log("AnyMoeCreator deployed to:", anymoecreator.address);

  const anymoenft = await AnyMoeNFT.deploy(anymoecreator.address);

  await anymoenft.deployed();

  console.log("AnyMoeNFT deployed to:", anymoenft.address);

  await anymoecreator.setNFTContractAddress(anymoenft.address);

  const anymoeauction = await AnyMoeAuction.deploy(anymoenft.address, 1, 5);

  await anymoeauction.deployed();

  console.log("AnyMoeAuction deployed to:", anymoeauction.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
