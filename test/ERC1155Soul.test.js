const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

describe("ERC1155Soul", function () {

  it("ERC1155Soul", async function () {
    let ERC1155Soul = await ethers.getContractFactory("ERC1155SoulMock");
    ERC1155Soul = await ERC1155Soul.deploy();
    await ERC1155Soul.deployed();

    let accounts = await ethers.getSigners();

    // pass a function to map
    const toMint = accounts.map(x => x.address); 

    await ERC1155Soul.mint(toMint);

    for (const i of Array(accounts.length).keys()) {
        for (const j of Array(accounts.length).keys()) {
            const expectedBalance = i==j ? 1 :0;
            expect(await ERC1155Soul.balanceOf(toMint[i], j)).to.equal(expectedBalance);
        }
    }

    await ERC1155Soul.mint(toMint);

    // previous tokens are not affected
    for (const i of Array(accounts.length).keys()) {
        for (const j of Array(accounts.length).keys()) {
            const expectedBalance = i==j ? 1 :0;
            expect(await ERC1155Soul.balanceOf(toMint[i], j)).to.equal(expectedBalance);
        }
    }

    const batchOffSet = 500;

    for (const i of Array(accounts.length).keys()) {
        for (const j of Array(accounts.length).keys()) {
            const expectedBalance = i==j ? 1 :0;
            expect(await ERC1155Soul.balanceOf(toMint[i], j+batchOffSet)).to.equal(expectedBalance);
        }
    }
  });


  it("ERC1155Soul with non-zero start token id", async function () {

    const startTokenId = 510;

    let ERC1155Soul = await ethers.getContractFactory("ERC1155SoulMockStartTokenId");
    ERC1155Soul = await ERC1155Soul.deploy(startTokenId);
    await ERC1155Soul.deployed();

    let accounts = await ethers.getSigners();

    // pass a function to map
    const toMint = accounts.map(x => x.address); 

    await ERC1155Soul.mint(toMint);

    for (const i of Array(accounts.length).keys()) {
        for (const j of Array(accounts.length).keys()) {
            const expectedBalance = i==j ? 1 :0;
            expect(await ERC1155Soul.balanceOf(toMint[i], j + startTokenId)).to.equal(expectedBalance);
        }
    }

    await ERC1155Soul.mint(toMint);
    for (const i of Array(accounts.length).keys()) {
        for (const j of Array(accounts.length).keys()) {
            const expectedBalance = i==j ? 1 :0;
            expect(await ERC1155Soul.balanceOf(toMint[i], j + startTokenId)).to.equal(expectedBalance);
        }
    }

    const batchOffSet = 500;

    for (const i of Array(accounts.length).keys()) {
        for (const j of Array(accounts.length).keys()) {
            const expectedBalance = i==j ? 1 :0;
            expect(await ERC1155Soul.balanceOf(toMint[i], j+batchOffSet+startTokenId)).to.equal(expectedBalance);
        }
    }
  });
});