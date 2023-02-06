import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { QTKN__factory, School, School__factory,QTKN,Token,Token__factory } from "../typechain-types";
import { BigNumber} from "ethers";

describe("School", function () {
  async function deployOneYearLockFixture() {
    const [school, teacher, student] = await ethers.getSigners();

    const price = ethers.utils.parseEther("8");
    const token = await ethers.getContractFactory("QTKN");
            const deploytoken = await token.deploy();
            console.log("QTKN Address : ",deploytoken.address);
    
            const token2 = await ethers.getContractFactory("Token");
            const deploytoken2 = await token2.deploy();
            console.log("StudentToken Address : ",deploytoken2.address);
    
            const CourseNft = await ethers.getContractFactory("QCourse");
            const deployCourseNft = await CourseNft.deploy();
            console.log("Course NFT Address : ",deployCourseNft.address);
    
            const CertNft = await ethers.getContractFactory("QCertificate");
            const deploycertnft = await CertNft.deploy();
            console.log("Certificate NFT Address : ",deploycertnft.address);

    const Contract:School__factory = await ethers.getContractFactory("School");
    const contract:School = await Contract.deploy(deploytoken.address,deploycertnft.address,deploytoken2.address,deployCourseNft.address,);

    await contract.deployed();

    const CertificateContract = await ethers.getContractFactory("QCertificate");
    const certificateContract = CertificateContract.attach(await contract.Ctf())
    
    const CourseNftContract = await ethers.getContractFactory("QCourse");
    const courseNftContract = CourseNftContract.attach(await contract.courseNFt())
    

    const Qtoken= await ethers.getContractFactory("QTKN");
    const Qtokencontract=Qtoken.attach(await contract.ERC());
    const Token=await ethers.getContractFactory("Token");
    const Utoken=await Token.attach(await contract.Utoken());
    console.log(`School contract: ${contract.address}\nCertificate contract address: ${certificateContract.address}\nCourseNFT contract address: ${courseNftContract.address}\nERC20 address: ${Qtokencontract.address}\n 
    ERc20Utoken : ${Utoken.address}`);
    return { certificateContract, contract, school, teacher, student, price, courseNftContract,Qtokencontract,Utoken};
  }

  async function CourseCreated() {
    const { certificateContract, contract, school, teacher, student, price, courseNftContract,Qtokencontract,Utoken } = await loadFixture(
      deployOneYearLockFixture
    );
    await contract.connect(teacher).createCourse("maths",101, teacher.address, 60, 100);

    return { certificateContract, contract, school, teacher, student, price, courseNftContract };
  }
  describe("Student Buy Tokens", function(){
    it("Should buy and verify tokens",async function () {
      const { certificateContract, contract, school, teacher, student, price, courseNftContract,Qtokencontract,Utoken } = await loadFixture(
        deployOneYearLockFixture
      );
     const Tokens=await contract.connect(student).GetTokens({value: price});
        console.log(Tokens);
     const Balance= await Qtokencontract.balanceOf(student.address);
        console.log(Balance);
    //  expect(await Qtokencontract.balanceOf(student.address)).to.equal(800);
  });

  describe("Deployment", function () {
    it("Should set the right price, tax, student status, owner", async function () {
      const { contract, price, school} = await loadFixture(deployOneYearLockFixture);
      expect(await contract.owner()).to.equal(school.address);
    });
  });

  describe("Create Course",function(){
    it("Should create course ",async function(){
      const {contract,teacher}= await loadFixture(
        deployOneYearLockFixture
      );
      await expect(contract.createCourse("Maths101",1, teacher.address,60, 10));
    });
  });

  describe("view terms of school",function(){
    it("Should return terms",async function(){
      const {contract}= await loadFixture(
        deployOneYearLockFixture
      );
      const term=await contract.viewTerm();
      await expect(term).to.equal(10); 

      const changeterm=await contract.ChangeBaseTerm(15);
      
      const baseterm=await contract.viewTerm();
      await expect(baseterm).to.equal(15);
    })
  });

  describe('Course price of course',function(){
    it("Should return course price",async function() {
      const {contract}= await loadFixture(
        CourseCreated
      );
      const price=await contract.ViewPrice(101);
     await expect(price).to.equal(170);
    })
  });

  describe('Enroll',function(){
    it("Should revert with the right error if course id does not exist", async function () {
      const { contract, student } = await loadFixture(CourseCreated);


      await expect(contract.connect(student).Enroll(4));
  });
  it("Should revert with the right error if student doesn't have tokens to pay for the course", async function () {
    const { contract , student } = await loadFixture(
      CourseCreated
    );

    await expect(contract.connect(student).Enroll(1));
  });});

  describe('Course Price Calculations',function(){
    it("Should calculate the course price correctly", async function () {
      const { contract ,price, teacher, student } = await loadFixture(CourseCreated);

      // await contract.connect(student).GetTokens(200, {value: price})
      const course2=await contract.createCourse("English",102, teacher.address, 80, 1000);
      const course3=await contract.createCourse("Scinece",103, teacher.address, 70, 800);
      const course4=await contract.createCourse("Scinece",104, teacher.address, 50, 900);
      const course5=await contract.createCourse("Scinece",105, teacher.address, 90, 500);
      const course6=await contract.createCourse("Scinece",106, teacher.address, 30, 650);
      expect(await contract.ViewPrice(101)).to.equal((170));
      expect(await contract.ViewPrice(102)).to.equal((1287));
      expect(await contract.ViewPrice(103)).to.equal((1176));
      expect(await contract.ViewPrice(104)).to.equal((1854));
      expect(await contract.ViewPrice(105)).to.equal((571));
      expect(await contract.ViewPrice(106)).to.equal((2230));
  });});
  describe('Enroll',function(){
    it("Should Enroll in the course", async function () {
      const { contract, student } = await loadFixture(CourseCreated);


      await expect(contract.connect(student).Enroll(101));
  });
});
describe('Graduate',function(){
    it("Should Enroll in the course", async function () {
      const { contract, student ,teacher} = await loadFixture(CourseCreated);

      await contract.connect(teacher).Graduation(1,101,student.address);
  });
});
});
});