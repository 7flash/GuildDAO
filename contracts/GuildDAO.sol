pragma solidity ^0.8.4;

abstract contract ERC20 {
    function totalSupply() public virtual view returns (uint);
    function balanceOf(address) public virtual view returns (uint);
    function transfer(address, uint) public  virtual returns (bool);
    function transferFrom(address, address, uint) public  virtual returns (bool);
    function approve(address, uint) public  virtual returns (bool);
    function allowance(address, address) public  virtual view returns (uint);
}

contract GuildDAO {
    uint256 nMembers;
    
    address[] members;
    
    mapping (address => bool) isMember;

    address[] applicants;

    mapping (address => bool) isApproved;

    uint256 priceToJoinTheGuild;
    uint256 maxMembers;

    uint256 dailyTokens = 1;

    address theOneWhoAllowedToKickOthers;

    mapping (address => bool) didITakeMyTokensToday;

    uint256 lastDayTimestamp;

    mapping (uint256 => uint256) numberOfVotesPerBuilding;

    address _token;

    constructor(
        uint256 _priceToJoinTheGuild,
        uint256 _maxMembers,
        address token
    ) public {
        priceToJoinTheGuild = _priceToJoinTheGuild;
        maxMembers = _maxMembers;
        _token = token;
    }

    function proposeNextBuildingModel(
        address _nextBuildingModel
    ) public {
        require(isMember[msg.sender]);
    }

    function takeMyTokensOnceAday() public  {
        require(didITakeMyTokensToday[msg.sender] == false);

        didITakeMyTokensToday[msg.sender] = true;

        ERC20(_token).transfer(msg.sender, dailyTokens);
    }

    function nextDaySunrise() public  {
        require(lastDayTimestamp + 86400 < block.timestamp);

        lastDayTimestamp = block.timestamp;

        // for each
        for (uint256 i = 0; i < members.length; i++) {
            didITakeMyTokensToday[members[i]] = false;
        }
    }

    function join()  public payable {
        // transfer ERC20 token to DAO
        ERC20(_token).transferFrom(msg.sender, address(this), priceToJoinTheGuild);

        require (isMember[msg.sender]);
        require (nMembers >= maxMembers);
        require (msg.value < priceToJoinTheGuild);

        members.push(msg.sender);
        isMember[msg.sender] = true;
        nMembers++;
    }

    // DEFAULT

    function addMember(address _member) public {
        require(isMember[_member] == false);
        members.push(_member);
        isMember[_member] = true;
        nMembers++;
    }

    function removeMember(address _member) public {
        require(isMember[_member] == true);
        uint256 i = 0;
        while (i < nMembers && members[i] != _member) {
            i++;
        }
        require(i < nMembers);
        members[i] = members[nMembers - 1];
        members.pop();
        isMember[_member] = false;
        nMembers--;
    }

    function getMember(uint256 _index) public view returns (address) {
        require(_index < nMembers);
        return members[_index];
    }

    function getMemberIndex(address _member) public view returns (uint256) {
        uint256 i = 0;
        while (i < nMembers && members[i] != _member) {
            i++;
        }
        require(i < nMembers);
        return i;
    }

    function isMemberOf(address _member) public view returns (bool) {
        return isMember[_member];
    }

    function getNumMembers() public view returns (uint256) {
        return nMembers;
    }
}