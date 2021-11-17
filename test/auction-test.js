const AnyMoeNFT = artifacts.require("AnyMoeNFT");
const AnyMoeAuction = artifacts.require("AnyMoeAuction");
const AnyMoeCreator = artifacts.require("AnyMoeCreator");

contract("AnyMoeAuction", (accounts) => {
  it("should create new auction and bid", async function () {
    const creatorInstance = await AnyMoeCreator.new(2, 30, {from: accounts[1]});
    const nftInstance = await AnyMoeNFT.new(creatorInstance.address, {from: accounts[1]});
    const auctionInstance = await AnyMoeAuction.new(nftInstance.address, 1, 5, {from: accounts[1]});
    await creatorInstance.setNFTContractAddress(nftInstance.address, {from: accounts[1]});

    await creatorInstance.adminInvite(accounts[0], {from: accounts[1]})
    await creatorInstance.mintNFT(accounts[0], 1, "uri://", {from: accounts[0]})

    await nftInstance.safeTransferFrom(accounts[0], auctionInstance.address, 0, 1, new Uint8Array(), {from: accounts[0]})
    
    let auction = await auctionInstance.createAuction(0, 1, web3.utils.toWei("0.5"), web3.utils.toWei("0.001"), 86400, {from: accounts[0]})
    let auctionId = auction.logs[0].args.auctionId.toNumber()

    let result = await auctionInstance.placeBid(auctionId, {from: accounts[0], value: web3.utils.toWei("0.5")})
    console.log(result.logs[0].args)

    result = await auctionInstance.placeBid(auctionId, {from: accounts[1], value: web3.utils.toWei("0.6")})
    console.log(result.logs[0].args)

    result = await auctionInstance.withdrawBid(auctionId, {from: accounts[0]})
    console.log(result.logs[0].args)

    result = await auctionInstance.getAuction(auctionId, {from: accounts[0]})
    console.log(result)
  });
});