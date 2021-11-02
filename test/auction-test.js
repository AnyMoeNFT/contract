const AnyMoeAuction = artifacts.require("AnyMoeAuction");

contract("AnyMoeAuction", (accounts) => {
  it("should create new auction and bid", async function () {
    const auctionInstance = await AnyMoeNFT.new("0x0");
    await auctionInstance.createAuction(0, 4, 1000, 277, 123)
  });
});