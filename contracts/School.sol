// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import './QTKN.sol';
import './certificate.sol';
import './Token.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
contract School is Ownable {
    //fix tax that would be calculated for course
    uint256 private constant tax = 3;
    //teacher mapping to course
    mapping(uint256=>address) courseTeacher;
    //teachershare in particular course
    mapping(uint256 =>uint256) teachershare;

    //course price mapping 
    mapping(uint256=>uint256) courseprice;

    //graduate mapping
    mapping(uint256=>mapping (address=>bool)) graduated;
    //base term scholl
    uint256  baseterm;
    //Qtkn initialized
    QTKN public ERC;
    //token for each course
    UniqueToken public Utoken;

    QCourse public courseNFt;

    constructor (){
        baseterm=10;
         }

    struct Course{
        uint256  courseId;
        string courseName;
        address teacher;
        uint256 teachershare;
        uint256 baseprice;
        bool registered;
         }
    //events
    event NewCourse(address indexed teacher,uint256 courseID,string coursename, uint256 price);
    //courses mapping;
    mapping(uint256=> Course) public courses;
    function createCourse(string memory _name,uint256 _courseID,address _teacher,uint256 _teacherShare,uint256 _basePrice )public{
        require(bytes(_name).length != 0) ;
        require (_courseID != 0);
        require (_teacher != address(0)) ;
        require (_basePrice != 0) ;
        require (_teacherShare != 0) ;
        require(courses[_courseID].registered==false,"Course Already Exists");
        require(baseterm<=100-_teacherShare,"Base term should be greater than school terms");
        courses[_courseID]=Course(_courseID,_name,_teacher,_teacherShare,_basePrice,true);
        courseTeacher[_courseID]=_teacher;
        teachershare[_courseID]=_teacherShare;
        courseprice[_courseID]=calculatePrice(courses[_courseID]);
        emit NewCourse(_teacher,_courseID,_name,_basePrice);
        courseNFt.mint(_teacher);
    }

    function ChangeBaseTerm(uint256 _terms)public{
        require(msg.sender==owner(),"Only owner can change base terms");
        baseterm=_terms;
    }

    function  GetTokens(uint256 _amount)public payable {
        require(msg.value==_amount*0.01 ether,'Amount is less you need more Eth!');
        ERC.BuyTokens(_amount);
    }

    function calculatePrice(Course storage _course) internal view returns (uint) {
        return (_course.baseprice + calculateSharePrice(_course) + calculateTaxPrice(_course));
    }

    //calculate share price
    function calculateSharePrice(Course storage _course) private view returns (uint) {
        return (_course.baseprice * _course.teachershare / 100);
    }

    //calculate tax price
    function calculateTaxPrice(Course storage _course) private view returns (uint) {
        return _course.baseprice * tax / 100;
    }


    function Enroll(uint256 _courseID) public payable{
        require(courses[_courseID].registered==true,"Course Does not exist");
        require(msg.value==courseprice[_courseID],"You need more token");
        require(msg.sender==address(0),'user not visible');
        Course storage cr= courses[_courseID];
        Utoken.mint(msg.sender);
        DistributeFee(cr);
    }


    function DistributeFee(Course storage _course) private {
        ERC.transfer(owner(),  calculateSharePrice(_course) + calculateTaxPrice(_course));
        ERC.transfer(_course.teacher,  _course.baseprice);
    }

    function ViewPrice(uint256 _courseID)public view returns(uint) {
         return courseprice[_courseID];
    }
    }