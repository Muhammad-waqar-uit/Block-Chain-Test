import { ethers } from "hardhat";
import { School, School__factory } from "../typechain-types";

async function main() {
  const [school, teacher, student] = await ethers.getSigners();

  const price = ethers.utils.parseEther("1");

  const Contract:School__factory = await ethers.getContractFactory("School");
  const contract:School = await Contract.deploy();

  await contract.deployed();

  console.log(contract.address);
}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
