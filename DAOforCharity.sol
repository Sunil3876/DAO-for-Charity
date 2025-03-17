// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract CharityDAO {
    // Struct to represent a charity organization
    struct Charity {
        string name;
        string description;
        address owner;
        uint256 funds;
        uint256 voteCount;
    }

    // Mapping of charity ID to charity
    mapping(uint256 => Charity) public charities;
    uint256 public charityCount;

    // Mapping of address to its vote status for each charity
    mapping(address => mapping(uint256 => bool)) public hasVoted;

    // Event to log charity creation
    event CharityCreated(uint256 indexed charityId, string name, string description, address owner);

    // Event to log voting
    event Voted(address indexed voter, uint256 indexed charityId);

    // Event to log fund contribution
    event Funded(uint256 indexed charityId, uint256 amount, address indexed contributor);

    // Modifier to check if the sender is the owner of the charity
    modifier onlyOwner(uint256 _charityId) {
        require(msg.sender == charities[_charityId].owner, "Only owner can perform this action");
        _;
    }

    // Modifier to check if the sender has already voted
    modifier hasNotVoted(uint256 _charityId) {
        require(!hasVoted[msg.sender][_charityId], "You have already voted");
        _;
    }

    // Modifier to ensure the contract has sufficient funds
    modifier sufficientFunds(uint256 _charityId) {
        require(charities[_charityId].funds > 0, "Insufficient funds in charity account");
        _;
    }

    // Function to create a new charity organization
    function createCharity(string memory _name, string memory _description) public {
        charityCount++;
        charities[charityCount] = Charity({
            name: _name,
            description: _description,
            owner: msg.sender,
            funds: 0,
            voteCount: 0
        });
        emit CharityCreated(charityCount, _name, _description, msg.sender);
    }

    // Function for users to contribute funds to a charity
    function fundCharity(uint256 _charityId) public payable {
        require(_charityId > 0 && _charityId <= charityCount, "Charity not found");
        charities[_charityId].funds += msg.value;
        emit Funded(_charityId, msg.value, msg.sender);
    }

    // Function for users to vote for a charity
    function voteForCharity(uint256 _charityId) public hasNotVoted(_charityId) {
        require(_charityId > 0 && _charityId <= charityCount, "Charity not found");
        charities[_charityId].voteCount++;
        hasVoted[msg.sender][_charityId] = true;
        emit Voted(msg.sender, _charityId);
    }

    // Function for charity owners to withdraw funds
    function withdrawFunds(uint256 _charityId, uint256 _amount) public onlyOwner(_charityId) sufficientFunds(_charityId) {
        require(_amount <= charities[_charityId].funds, "Insufficient funds");
        charities[_charityId].funds -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    // Function to get the details of a charity
    function getCharityDetails(uint256 _charityId) public view returns (string memory, string memory, address, uint256, uint256) {
        Charity memory charity = charities[_charityId];
        return (charity.name, charity.description, charity.owner, charity.funds, charity.voteCount);
    }
}
