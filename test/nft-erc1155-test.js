const AnyMoeNFT = artifacts.require("AnyMoeNFT");

contract("AnyMoeNFT", (accounts) => {
  it("Should Create New NFTs", async function () {
    const anymoeInstance = await AnyMoeNFT.new();
    await anymoeInstance.mintNFT(accounts[0], accounts[0], 1, "uri://")
    await anymoeInstance.mintNFT(accounts[1], accounts[1], 3, "uri://moe")
    let uri = await anymoeInstance.uri(0)
    console.log(uri)
    await anymoeInstance.safeTransferFrom(accounts[1], accounts[0], 1, 2, new Uint8Array(), {from: accounts[1]})
    let balance = await anymoeInstance.balanceOf(accounts[0], 0)
    console.log(balance)
    balance = await anymoeInstance.balanceOf(accounts[0], 1)
    console.log(balance)
  });
});