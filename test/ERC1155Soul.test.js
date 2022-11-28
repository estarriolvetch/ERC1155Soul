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
            let batchBalance = await ERC1155Soul.balanceOfBatch(toMint, Array(accounts.length).fill(j));
            for (const k of Array(accounts.length).keys()) {
                const expectedBalance2 = k==j ? 1 :0;
                expect(batchBalance[k]).to.equal(expectedBalance2);
            }
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
        
            let batchBalance = await ERC1155Soul.balanceOfBatch(toMint, Array(accounts.length).fill(j + startTokenId));
            for (const k of Array(accounts.length).keys()) {
                const expectedBalance2 = k==j ? 1 :0;
                expect(batchBalance[k]).to.equal(expectedBalance2);
            }
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

  it("Querying non-existing token (batch doesn't exist.)", async function () {
    let ERC1155Soul = await ethers.getContractFactory("ERC1155SoulMock");
    ERC1155Soul = await ERC1155Soul.deploy();
    await ERC1155Soul.deployed();

    let accounts = await ethers.getSigners();

    expect(await ERC1155Soul.balanceOf(accounts[0].address, 0)).to.equal(0);

    });

    it("Querying non-existing token (same batch but outside the storage)", async function () {
        let ERC1155Soul = await ethers.getContractFactory("ERC1155SoulMock");
        ERC1155Soul = await ERC1155Soul.deploy();
        await ERC1155Soul.deployed();

        let accounts = await ethers.getSigners();
        const toMint = accounts.map(x => x.address);

        await ERC1155Soul.mint([accounts[0].address]);

        // Sanity check make sure the token is minted.
        expect(await ERC1155Soul.balanceOf(accounts[0].address, 0)).to.equal(1);

        expect(await ERC1155Soul.balanceOf(accounts[0].address, 1)).to.equal(0);
    });

    it("Querying non-existing token (smaller than the start token id)", async function () {
        const startTokenId = 510;

        let ERC1155Soul = await ethers.getContractFactory("ERC1155SoulMockStartTokenId");
        ERC1155Soul = await ERC1155Soul.deploy(startTokenId);
        await ERC1155Soul.deployed();;

        let accounts = await ethers.getSigners();
        const toMint = accounts.map(x => x.address);

        await ERC1155Soul.mint([accounts[0].address]);

        // Sanity check make sure the token is minted.
        expect(await ERC1155Soul.balanceOf(accounts[0].address, 510)).to.equal(1);

        expect(await ERC1155Soul.balanceOf(accounts[0].address, 509)).to.equal(0);
        expect(await ERC1155Soul.balanceOf(accounts[0].address, 0)).to.equal(0);
    });

});