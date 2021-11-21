const hre = require("hardhat");
async function main() {
  const AnyMoeNFT = await hre.ethers.getContractFactory("AnyMoeNFT");
  const AnyMoeAuction = await hre.ethers.getContractFactory("AnyMoeAuction");
  const AnyMoeCreator = await hre.ethers.getContractFactory("AnyMoeCreator");

  const AnyMoeCreatorInstance = AnyMoeCreator.attach("0x572Dde881acf43fEA17060d8E927b359bF780C2c")
  const AnyMoeNFTInstance = AnyMoeNFT.attach("0xC5f06C1e1D0F353344614B0FBe3a42ecB2CFda00")
  const AnyMoeAuctionInstance = AnyMoeAuction.attach("0xA9CB72c31afE60Bf2601a6A42E197d2336f63B8E")

  await AnyMoeCreatorInstance.mintNFT("0x282922091B1565C32A3a48B151bad27FF4579e49", 1, "ipfs://QmawafjQXMjgKSxwDWdaU1gqMEth3Sj8NRew74YoHaaQAX/metadata.json")
}
main().then(() => process.exit(0)).catch(error => {
  console.error(error)
  process.exit(1)
});