// const { expect } = require("chai");
// const { ethers } = require("hardhat");

// describe("School contract", function(){
//     let School;
//     let SchoolToken;
//     let school;
//     let teacher;
//     let student;

//   beforeEach(async function() {
//     School = await ethers.getContractFactory("School");
//     [school,teacher,student]=await ethers.getSigners();
//     SchoolToken=await School.deploy;
//   });

//   describe("Create Course",function(){
//     it("Should Create Course",async function(){
//         const tx= await SchoolToken.createCourse("Maths 101",1,teacher.address,60,100);
//         await tx.wait();
//         const course= SchoolToken.courses(1);
//         expect(course.courseName).to.equal("Maths 101");
//     })
//   })
// //   it("should create a new course", async () => {
// //     const tx = await School.createCourse("Math 101", 1, teacher.address, 10, 1);
// //     await tx.wait();
// //     const course = await School.courses(1);
// //     expect(course.courseName).to.equal("Math 101");
// //     expect(course.teacher).to.equal(teacher.address);
// //     expect(course.teacherShare).to.equal(10);
// //     expect(course.basePrice).to.equal(1);
// //   });

// //   it("should enroll a student in a course", async () => {
// //     await School.createCourse("Math 101", 1, teacher.address, 10, 1);
// //     await School.getTokens(10, { value: ethers.utils.parseEther("0.1") });
// //     await student.sendTransaction({ to: School.address, value: ethers.utils.parseEther("0.01") });
// //     const tx = await School.enroll(1);
// //     await tx.wait();
// //     const enrollement = await school.studentEnrollement(1, 1);
// //     expect(enrollement).to.equal(student.address);
// //   });

// });
import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { QTKN__factory, School, School__factory } from "../typechain-types";
import { BigNumber} from "ethers";

describe("School", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearLockFixture() {
    const [school, teacher, student] = await ethers.getSigners();

    const price = ethers.utils.parseEther("2");

    const Contract:School__factory = await ethers.getContractFactory("School");
    const contract:School = await Contract.deploy();

    await contract.deployed();

    const CertificateContract = await ethers.getContractFactory("QCertificate");
    const certificateContract = CertificateContract.attach(await contract.Ctf())
    
    const CourseNftContract = await ethers.getContractFactory("QCourse");
    const courseNftContract = CourseNftContract.attach(await contract.courseNFt())
  
    console.log(`School/ERC20 contract: ${contract.address}\nCertificate contract address: ${certificateContract.address}\nCourseNFT contract address: ${courseNftContract.address}`);
    return { certificateContract, contract, school, teacher, student, price, courseNftContract };
  }

  async function CourseCreated() {
    const { certificateContract, contract, school, teacher, student, price, courseNftContract } = await loadFixture(
      deployOneYearLockFixture
    );
    await contract.connect(teacher).createCourse("maths",101, teacher.address, 60, 100);

    return { certificateContract, contract, school, teacher, student, price, courseNftContract };
  }

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
      const price=await contract.ViewPrice(1);
      // await expect(price).to.equal(170);
    })
  });

  describe('Enroll',function(){
    it("Should revert with the right error if course id does not exist", async function () {
      const { contract , teacher, student } = await loadFixture(CourseCreated);


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


});