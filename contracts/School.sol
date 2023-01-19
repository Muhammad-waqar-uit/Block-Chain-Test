// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract School {
    address public owner;
    uint256 private baseterm;
    uint256 private tax=3;
    //events
    event NewCourse(address indexed teacher,uint256 courseID, uint256 price);
    event Newteacher(address indexed teacher);
    event Changebaseterm(uint256 newterm);
    //mapping for teacher 
    mapping (address=>bool) teacher;

    //mapping for the course and teacher assign
    mapping (address=> mapping(uint256=>address)) public courses;

    //mapping teacher of course
    mapping(uint256=>address) public teachersofcourse;

    //mapping teacher share
    mapping(uint256=>uint256) public teachershare; 
    //course price mapping
    mapping (uint256=>uint256) public courseprice;

    //school share mapping
    mapping (uint256=>uint256) public schoolshare;

    //mapping for course and link
    mapping (uint256=>string) links;


    constructor (){
        owner=msg.sender;
        baseterm=90;
        }

    function createCourse(address _teacher,uint256 _courseId, uint _basePrice, uint _teacherShare,string memory courselink) public {
        require(teacher[_teacher] == true, "You are not a registered teacher");
         require(courses[_teacher][_courseId] == _teacher, "Course already exists for this");
         require(_teacherShare <= baseterm, "Teacher share must be less than or equal to the base term set by the school"); 
         links[_courseId]=courselink;
         uint _schoolShare = baseterm - _teacherShare;
         uint _price = (_basePrice * 3 / 100)+_basePrice+_schoolShare;
         courseprice[_courseId] = _price;
         teachershare[_courseId] = _teacherShare;
         schoolshare[_courseId] = _schoolShare;
         teachersofcourse[_courseId] = _teacher;
         courses[_teacher][_courseId] = _teacher;
         emit NewCourse(_teacher, _courseId, courseprice[_courseId]);
    }
    
    function  addTeacher(address _name) public{
     require(msg.sender==owner,"Only owner can add teacher");
     require(_name==address(0),"Invalid Address");
     require(teacher[_name]==false,'Teacher Already Exist');
     teacher[_name]=true;
     emit Newteacher(_name);
    }

    function changebaseterm(uint256 value)public {
        require(msg.sender==owner,"Only owner can change the base terms");
        baseterm=value;
        emit Changebaseterm(value);
    }
    function getCoursePrice(uint256 _courseId) public view returns (uint) {
    return courseprice[_courseId];
    }

    function getTeacherShare(uint256 _courseId) public view returns (uint) {
        return teachershare[_courseId];
    }

    function getSchoolShare(uint256 _courseId) public view returns (uint) {
        return schoolshare[_courseId];
    }

    function getTeacherOfCourse(uint256 _courseId) public view returns (address) {
        return teachersofcourse[_courseId];
    }
     
     function BuyCourse(uint256 _courseID, uint256 _pay) public payable {
        
     }

}