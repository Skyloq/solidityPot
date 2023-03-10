pragma solidity ^0.8.0;

contract Lottery {
    address public manager;
    mapping(address => uint) public investments;
    address payable[] public players;

    event NewPlayer(address player);
    event Winner(address winner, uint amount);
    uint public totalAmount = 0;

    constructor() {
        manager = msg.sender;
    }

    function enter() public payable {
        require(msg.value > 0.0001 ether);
        totalAmount += msg.value;
        players.push(payable(msg.sender));
        investments[msg.sender] += msg.value;
        emit NewPlayer(msg.sender);
    }

    function pickWinner() public restricted {
        require(players.length > 0);
        uint index = generateRandomIndex();
        address payable winner = players[index];
        uint amount = totalAmount;
        winner.transfer(amount);
        totalAmount = 0;
        reset();
        emit Winner(winner, amount);
    }

    function generateRandomIndex() private view returns (uint) {
        uint totalInvestments = 0;
        for (uint256 i = 0; i < players.length; i++) {
            totalInvestments += investments[players[i]];
        }
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, totalInvestments)));
        uint256 index = 0;
        uint256 previousPercentage = 0;
        for (uint256 i = 0; i < players.length; i++) {
            uint256 playerPercentage = investments[players[i]] * 100 / totalInvestments;
            if (randomNumber >= previousPercentage && randomNumber < (previousPercentage + playerPercentage)) {
                index = i;
                break;
            }
            previousPercentage += playerPercentage;
        }
        return index;
    }

    function reset() private {
        for (uint256 i = 0; i < players.length; i++) {
            investments[players[i]] = 0;
        }
        players = new address payable[](0);
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function getTotalAmount() public view returns (uint){
        return totalAmount;
    }

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
}