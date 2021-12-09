const hre = require("hardhat");
async function main() {
  const AnyMoeNFT = await hre.ethers.getContractFactory("AnyMoeNFT");
  const AnyMoeAuction = await hre.ethers.getContractFactory("AnyMoeAuction");
  const AnyMoeCreator = await hre.ethers.getContractFactory("AnyMoeCreator");

  const AnyMoeCreatorInstance = AnyMoeCreator.attach("0x0B3eEFEa1306A7614dD18FE09732dE6763569553")
  const AnyMoeNFTInstance = AnyMoeNFT.attach("0x1054B0E3c535cefE9Ee98A6fCa7BD0f8F42c0297")
  const AnyMoeAuctionInstance = AnyMoeAuction.attach("0xc5BbB1ADc5885EA8049612Eb767588096D7E2ca9")

  //await AnyMoeCreatorInstance.adminInvite("0x282922091B1565C32A3a48B151bad27FF4579e49")
  await AnyMoeCreatorInstance.mintNFT("0x282922091B1565C32A3a48B151bad27FF4579e49", 5, "ipfs://QmbNVErzyyvDF2Bcc9mRy8tDWb8EbqWj1m6k79roEHK4Y5")
  //await AnyMoeNFTInstance.safeTransferFrom("0x282922091B1565C32A3a48B151bad27FF4579e49", "0x24cc0d58fD9E208E09e8FC5a01592e7C8A924018", 0, 1, new Uint8Array())
}
main().then(() => process.exit(0)).catch(error => {
  console.error(error)
  process.exit(1)
});