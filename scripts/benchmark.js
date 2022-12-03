// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {

  //const ERC1155Soul = await hre.ethers.getContractFactory("ERC1155SoulMock");
  const ERC1155Soul = await hre.ethers.getContractFactory("ERC1155SoulContinuousMock");
  const erc1155soul = await ERC1155Soul.deploy();

  await erc1155soul.deployed();


  const accounts = await ethers.getSigners();
  const deployer = accounts[0];
  const tos = Array(500 ).fill(deployer.address);
  //console.log(tos);

  let tx = await erc1155soul.mint(tos);
  tx = await tx.wait();
  console.log("total gas:", tx.gasUsed.toString());
  console.log("per token gas:", tx.gasUsed.div(tos.length).toString());

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
