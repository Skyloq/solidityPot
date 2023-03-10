pragma solidity ^0.8.0;

contract Lottery {

    enum State { Active, Close }


    address public manager;

    mapping (address => uint) players_amount;
    address[] public players;

    address payable private winner;
    State public state;

    uint public currentTime = block.timestamp;

    event LotteryEnter(address player, uint amount);
    event Winner(address winner, uint amount);
    uint public totalAmount = 0;

    constructor() {
        manager = msg.sender;
        state = State.Active;
    }

    function enter() public payable {
        require(msg.value > 0.0001 ether);

        bool credited = false;
        for(uint i = 0; i < players.length; i ++){
            if(players[i] == msg.sender){
                players_amount[msg.sender] += msg.value;
            }
        }

        if(!credited){
            players_amount[msg.sender] = msg.value;
            players.push(payable(msg.sender));
        }

        totalAmount += msg.value;
        emit LotteryEnter(msg.sender, msg.value);
    }

    function pickWinner() public restricted {
        require(players.length > 0);

        uint winAmountIndex = uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, totalAmount)));
        uint amountIndex = 0;

        for(uint i = 0; i < players.length; i ++){
            address currentPlayer = players[i];
            if(winAmountIndex > amountIndex && winAmountIndex <= amountIndex + players_amount[currentPlayer]){
                winner = payable(currentPlayer);
            }
            amountIndex += players_amount[currentPlayer];
        }
        
        uint amount = address(this).balance;
        winner.transfer(amount);

        for (uint i = 0; i < players.length; i++) {
            players_amount[players[i]] = 0;
        }
        players = new address[](0);
        emit Winner(winner, amount);
    }

    function getPlayers() public view returns (address[] memory) {
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