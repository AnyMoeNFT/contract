const AnyMoeNFT = artifacts.require("AnyMoeNFT");

contract("AnyMoeNFT", (accounts) => {
  it("Should Create New NFTs", async function () {
    const nftInstance = await AnyMoeNFT.new();
    await nftInstance.mintNFT(accounts[0], 1, "uri://")
    await nftInstance.mintNFT(accounts[1], 3, "uri://moe")
    let uri = await nftInstance.uri(0)
    assert.equal(uri, "uri://")
    await nftInstance.safeTransferFrom(accounts[1], accounts[0], 1, 2, new Uint8Array(), {from: accounts[1]})
    let balance = await nftInstance.balanceOf(accounts[0], 0)
    assert.equal(balance, 1)
    balance = await nftInstance.balanceOf(accounts[0], 1)
    assert.equal(balance, 2)
  });
});