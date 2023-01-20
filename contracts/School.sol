// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import './QTKN.sol';
import './certificate.sol';
contract School is Ownable,ERC20 {
    //public price for conversion of coins
    uint public eprice=0.01 ether;
    //fix tax that would be calculated for course
    uint256 public tax=3;
    //base term scholl
    uint256  baseterm=10;

    //iniatilize the contract
    QCertificate public certification;
    QCourse public courseNFT;


    //constant enumerations
      enum status {enroll, not_enroll, course_completed}
    //mapping for teacher 
    mapping (address=>bool) teacher;

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

    function mint(uint256 _amount)public payable {
            require(msg.value==(_amount*eprice),"Not having amount to generate tokens");
            _mint(msg.sender, _amount);
    }



    constructor () ERC20('QCourse',"QTKN"){
        certification= new QCertificate();
        courseNFT= new QCourse();
        baseterm=90;
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
        transfer(owner(),toOwner(_course));
        transfer(_course.teacher, _course.baseprice);
    }
    function enrollcourse(uint _courseid) public{
        require(msg.sender!=address(0),"gosted account");
        require(_courseid<courses.length,'Course does not exist');

        Course storage cr=courses[_courseid];
        cr.students[msg.sender]= status.enroll;
        distributefee(cr);
    }
}