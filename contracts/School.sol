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

    //Course Mapping
    mapping (uint256 => mapping (uint256 => address)) studentEnrollement;

    //graduate mapping
    mapping(uint256 => mapping(uint256 => mapping(address => bool))) Graduate;
    //base term scholl
    uint256  public baseterm;
    //Qtkn initialized
    QTKN public ERC;
    //token for each course
    Token public Utoken;

    QCourse public courseNFt;

    QCertificate public Ctf;
    constructor (){
        baseterm = 10;
        courseNFt = new QCourse();
        Ctf = new QCertificate();
        ERC = new QTKN();
        Utoken = new Token();
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
    event BaseTermChange(address indexed from,uint256 base);
    event Enrolled(address indexed student,uint256 tokenid,uint256 coourseid);
    event Graduated(address indexed student,uint256 tokenid,uint256 coourseid,bool clear);
    event ClaimedNFTCertificate(address indexed student,uint256 tokenid,uint256 coourseid,bool check);
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
        courseprice[_courseID] = coursePricecalculator(_basePrice,_teacherShare);
        emit NewCourse(_teacher,_courseID,_name,_basePrice);
        courseNFt.mint(msg.sender);
    }

    function ChangeBaseTerm(uint256 _terms)public{
        require(msg.sender==owner(),"Only owner can change base terms");
        baseterm=_terms;
        emit BaseTermChange(msg.sender,_terms);
    }

    function  GetTokens(uint256 _amount)public payable {
        require(msg.value==_amount*0.01 ether,'Amount is less you need more Eth!');
        ERC.BuyTokens(_amount);
    }

    function coursePricecalculator(uint256 _basePrice,uint256 _teacherShare) private pure returns (uint){
        return (calculatePercentage(_basePrice,_teacherShare)+calculateTax(calculatePercentage(_basePrice,_teacherShare)));
    }

    function calculatePercentage(uint base, uint share) public pure returns (uint) {
    return (base * 100) / share;
    }

    function calculateTax(uint amount) public pure returns (uint) {
    return amount * 3 / 100;
    }


    function Enroll(uint256 _courseID) public{
        require(courses[_courseID].registered==true,"Course Does not exist");
        require(ERC.balanceOf(msg.sender)==courseprice[_courseID],"You need more token");
        require(msg.sender==address(0),'user not visible');
        Utoken.EnrollementToken();
        studentEnrollement[Utoken.counter()][_courseID]=msg.sender;
        Graduate[Utoken.counter()][_courseID][msg.sender]=false;
        Course storage c=courses[_courseID];
        ERC.transferFrom(msg.sender,c.teacher,c.baseprice);
        ERC.transferFrom(msg.sender,address(this),coursePricecalculator(c.baseprice,c.teachershare)-c.baseprice);
        emit Enrolled(msg.sender,Utoken.counter(),_courseID);
    }

    function ViewPrice(uint256 _courseID)public view returns(uint) {
         return courseprice[_courseID];
    }


    function call_Graduate(uint256 _tokenid,uint256 _courseID,address _student)public{
        Course storage c=courses[_courseID];
        require(msg.sender==c.teacher);
        require(studentEnrollement[_tokenid][_courseID]==_student,'Not Enrolled in the course');
        require(!Graduate[_tokenid][_courseID][_student], "Already Graduated");
        Graduate[_tokenid][_courseID][_student]=true;
        emit Graduated(msg.sender,_tokenid,_courseID,true);
    }



    function Claim(uint256 _tokenid,uint256 _courseID)public{
        require(msg.sender==studentEnrollement[_tokenid][_courseID],"Your are Not enrolled");
        require(Graduate[_tokenid][_courseID][msg.sender]==true,"You are not graduate yet!.");
        Ctf.mint(msg.sender);
        Utoken.Burn();
        emit ClaimedNFTCertificate(msg.sender,_tokenid,_courseID,true);
    }


    function viewTerm() public view returns(uint){
        return baseterm;
    }
    }

//     mapping(uint256 => mapping(uint256 => address)) public nestedMapping;
// mapping(uint256 => bool) public wholeMapping;
// nestedMapping[key1][key2] = value;
// address value = nestedMapping[key1][key2];
// wholeMapping[key] = value;
