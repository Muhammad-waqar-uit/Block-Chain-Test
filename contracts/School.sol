// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import './QTKN.sol';
import './Token.sol';
import './certificate.sol';
contract School is Ownable {
    //public price for conversion of coins
    uint public eprice=0.01 ether;
    //fix tax that would be calculated for course
    uint256 public tax=3;
    //base term scholl
    uint256  baseterm;
    //initialize the erc
    QTKN public ERC;

    //initalization for the Qcourse Token

    Token public Qtoken;
    //iniatilize the contract
    QCertificate public certification;
    QCourse public courseNFT;


    //constant enumerations
    enum status {enroll, not_enroll, course_completed}
    //mapping for teacher 
    mapping (address=>bool) teacher;

    //mapping teacher of course
    mapping(string=>address) public teachersofcourse;

    //mapping teacher share
    mapping(string=>uint256) public teachershare; 
    //course price mapping
    mapping (string=>uint256) public courseprice;

    //school share mapping
    mapping (string=>uint256) public schoolshare;
    
    //created array unassigned size
    Course[] public courses;

    //events
    event NewCourse(address indexed teacher,uint256 courseID, uint256 price);
    event Newteacher(address indexed teacher);
    event Changebaseterm(uint256 newterm);
    //course complete
    event CourseCompleted(address indexed student,uint256 courseid);


    modifier onlyTeacher(){
        require(teacher[msg.sender]==true,"Not authorize to create a course");
        _;
    }

    constructor (){
        baseterm=10;
        }

    function  addTeacher(address _name) public onlyOwner{
     teacher[_name]=true;
     emit Newteacher(_name);
    }

    function SetTax(uint256 _tax) public onlyOwner {
        tax=_tax;
    }

     function changebaseterm(uint256 value)public onlyOwner{
        baseterm=value;
        emit Changebaseterm(value);
    }

    function  GetTokens(uint256 _amount)public payable {
        require(msg.value==_amount*0.01 ether,'Amount is less you need more Eth!');
        ERC.BuyTokens(_amount);
    }

    struct Course{
        string name;
        uint256 courseId;
        address teacher;
        uint baseprice;
        uint teachershare;
        uint courseprice;
        mapping(address => status) students;
    }

    function Calculateprice(Course storage _course) internal view returns(uint) {
        return(_course.baseprice+(_course.baseprice*(tax/100))+(((100-_course.teachershare)/100)*_course.baseprice));
    }


    function coursecomplete(address _student, uint256 _courseid) public onlyTeacher{
        require(courses[_courseid].students[_student]==status.enroll,"Student not enrolled");
        courses[_courseid].students[_student]=status.course_completed;
        emit CourseCompleted(_student, _courseid);
        certification.mint(_student);
    }

    function createCourse(string memory _name,
    address _teacher, uint256 _baseprice, uint256 _teachershare)public onlyTeacher{
        require(100-_teachershare>=baseterm,"Share should be higher than baseterm");
        require(msg.sender!=address(0),'ghosted account');
        Course storage cr= courses.push();
        cr.name=_name;
        cr.courseId=courses.length-1;
        cr.teacher=_teacher;
        cr.baseprice=_baseprice;
        cr.teachershare=_teachershare;
        cr.courseprice=Calculateprice(cr);
        teachersofcourse[_name] = _teacher;
        teachershare[_name]=_teachershare;
        schoolshare[_name]=100-_teachershare;
        courseprice[_name]=cr.courseprice;
        courseNFT.mint(_teacher);
        emit NewCourse(_teacher, courses.length-1, _baseprice);
    }

    function viewprice(uint _courseid) public view returns(uint){
        return courses[_courseid].courseprice;
    }

    function toOwner(Course storage c) private view returns (uint){
        return((c.baseprice*(tax/100))+c.baseprice*((100-c.teachershare)/100));
    }

    function distributefee(Course storage _course) private {
        ERC.transfer(owner(),toOwner(_course));
        ERC.transfer(_course.teacher, _course.baseprice);
    }
    function enrollcourse(uint _courseid) public{
        require(msg.sender!=address(0),"gosted account");
        require(_courseid<courses.length,'Course does not exist');
        Qtoken.BuyCourseToken(1);
        Course storage cr=courses[_courseid];
        cr.students[msg.sender]= status.enroll;
        distributefee(cr);
    }

     function getCoursePrice(string memory _name) public view returns (uint) {
    return courseprice[_name];
    }

    function getTeacherShare(string memory _name) public view returns (uint) {
        return teachershare[_name];
    }

    function getSchoolShare(string memory _name) public view returns (uint) {
        return schoolshare[_name];
    }

    function getTeacherOfCourse(string memory _name) public view returns (address) {
        return teachersofcourse[_name];
    }
}