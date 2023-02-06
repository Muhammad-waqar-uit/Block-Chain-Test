// import { expect } from 'chai';
// import { BigNumber} from "ethers";
// import { ethers } from "hardhat";
// import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
// import {QCourse, QCourse__factory,QCertificate, QCertificate__factory,QTKN, QTKN__factory,Token, Token__factory, School__factory, School } from "../typechain-types";



// describe ("School",  function () {
//     beforeEach(async function(){
//         const [school, teacher, student] = await ethers.getSigners();
        
//         const token = await ethers.getContractFactory("QTKN");
//         const deploytoken = await token.deploy();
//         console.log("QTKN Address : ",deploytoken.address);

//         const token2 = await ethers.getContractFactory("Token");
//         const deploytoken2 = await token2.deploy();
//         console.log("StudentToken Address : ",deploytoken2.address);

//         const CourseNft = await ethers.getContractFactory("QCourse");
//         const deployCourseNft = await CourseNft.deploy();
//         console.log("Course NFT Address : ",deployCourseNft.address);

//         const CertNft = await ethers.getContractFactory("QCertificate");
//         const deploycertnft = await CertNft.deploy();
//         console.log("Certificate NFT Address : ",deploycertnft.address);

//         const Contract = await ethers.getContractFactory("School");
//         const contract =await Contract.deploy(deploytoken.address, deploytoken2.address, deployCourseNft.address, deploycertnft.address);
//         console.log("School Address : ",contract.address);
//     });
//     describe("Course Creation",function(){
//         it("Should create the course",async function () {
//     })
// })
// })