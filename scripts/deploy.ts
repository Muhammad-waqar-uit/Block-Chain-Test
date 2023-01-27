import { ethers } from "hardhat";
import { School, School__factory } from "../typechain-types";


async function main() {
    const [school,teacher,student] =await ethers.getSigners();

    const School =await ethers.getContractFactory("School");

    const deploy =await School.deploy();
    console.log("School contract address : ",deploy.address);
    
}

main()
.then(()=> process.exit(0))
.catch((error)=>{
    console.error(error);
    process.exit(1);
})