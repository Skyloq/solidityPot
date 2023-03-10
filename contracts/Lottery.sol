pragma solidity ^0.8.0;

contract Lottery {

    enum State { Active, Close }

    uint randNonce = 0;

    address public manager;

    mapping (address => uint) players_amount;
    address[] public players;

    address payable private winner;
    State private state;

    uint private currentTime = block.timestamp;

    event LotteryEnter(address player, uint amount);
    event Winner(address winner, uint amount);
    uint private totalAmount = 0;

    constructor() {
        manager = msg.sender;
        state = State.Active;
    }

    //Extend payable, mean it need a transaction on blockchain to be executed
    //Add a new ticket to the list of ticket
    function enter() public payable {
        require(msg.value > 0.0001 ether);

        bool credited = false;
        for(uint i = 0; i < players.length; i ++){
            if (players[i] == msg.sender){
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

    //Choose a winner by choosing a random ticket, consedering the value of each ticket
    function pickWinner() public restricted {
        require (players.length > 0);

        uint winAmountIndex = randMod(totalAmount);
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

    //Return the total amount of the pot
    function getTotalAmount() public view returns (uint){
        return totalAmount;
    }

    //Return the state of the lottery
    function getState() public view returns (State) {
        return state;
    }

    //Not implemented
    function getCurrentTime() public view returns (uint) {
        return currentTime;
    }

    //Return every ticket buyed
    function getPlayers() public view returns (address[] memory) {
        return players;
    }

    //To define
    function randMod(uint _modulus)private returns(uint)
    {
        randNonce++;
        return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % _modulus;
    }

    //Control access in a require function
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
}