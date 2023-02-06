import { ethers } from "hardhat";
import { School, School__factory } from "../typechain-types";

async function Main() {

    const [school,teacher,student] =await ethers.getSigners();
    const School =await ethers.getContractFactory("School");

    const token = await ethers.getContractFactory("QTKN");
    const deploytoken =await token.deploy();
    console.log("Qtkn Address : ", deploytoken.address);

    const token2 = await ethers.getContractFactory("Token");
    const deploytoken2 =await token2.deploy();
    console.log("Course Token Address : ", deploytoken2.address);

    const coursenft = await ethers.getContractFactory("QCourse");
    const deployNFT =await coursenft.deploy();
    console.log("Course NFT Address : ", deployNFT.address);

    const grad = await ethers.getContractFactory("QCertificate");
    const deployCert =await grad.deploy();
    console.log("Certificate NFT Address : ", deployCert.address);

    const deploy =await School.deploy(deploytoken.address, deploytoken2.address, deployNFT.address, deployCert.address);
    console.log("School contract address : ",deploy.address);
} 

Main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });