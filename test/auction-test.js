const AnyMoeNFT = artifacts.require("AnyMoeNFT");
const AnyMoeAuction = artifacts.require("AnyMoeAuction");

contract("AnyMoeAuction", (accounts) => {
  it("should create new auction and bid", async function () {
    const nftInstance = await AnyMoeNFT.new();
    const auctionInstance = await AnyMoeAuction.new(nftInstance.address, 1);

    await nftInstance.mintNFT(accounts[0], 1, "uri://")
    await nftInstance.safeTransferFrom(accounts[0], auctionInstance.address, 0, 1, new Uint8Array(), {from: accounts[0]})
    
    let auction = await auctionInstance.createAuction(0, 1, web3.utils.toWei("0.5"), web3.utils.toWei("0.001"), 86400)
    console.log(auction.logs[0].args.auctionId.toNumber())

  });
});