pragma solidity ^0.8.0;

contract Lottery {

    enum State { Active, Close }

    struct Player {
        address player_address;
        uint amount_bet;
    }

    uint lotteryNumber = 1;
    uint randNonce = 0;

    address public owner;

    //Players data by lottery number
    mapping(uint => mapping(address => Player)) private players_data;
    //Players by lottery number
    mapping(uint => address[]) public players;

    address payable private winner;
    State private state;

    uint private currentTime = block.timestamp;

    event LotteryEnter(address player, uint amount);
    event Winner(address winner, uint amount);
    uint private totalAmount = 0;

    constructor() {
        owner = msg.sender;
        state = State.Active;
    }

    //Extend payable, mean it need a transaction on blockchain to be executed
    //Add a new ticket to the list of ticket
    function enter() public payable {
        require(msg.value > 0.0001 ether);

        bool credited = false;
        for(uint i = 0; i < players[lotteryNumber].length; i ++){
            if (players[lotteryNumber][i] == msg.sender){
                players_data[lotteryNumber][msg.sender].amount_bet += msg.value;
                players_data[lotteryNumber][msg.sender].player_address = msg.sender;
            }
        }

        if(!credited){
            players_data[lotteryNumber][msg.sender].amount_bet = msg.value;
            players_data[lotteryNumber][msg.sender].player_address = msg.sender;
            players[lotteryNumber].push(payable(msg.sender));
        }

        totalAmount += msg.value;
        emit LotteryEnter(msg.sender, msg.value);
    }

    //Choose a winner by choosing a random ticket, consedering the value of each ticket
    function pickWinner() public restricted {
        require (players[lotteryNumber].length > 0);

        uint winAmountIndex = randMod(totalAmount);
        uint amountIndex = 0;

        for(uint i = 0; i < players[lotteryNumber].length; i ++){
            address currentPlayer = players[lotteryNumber][i];
            if(winAmountIndex > amountIndex && winAmountIndex <= amountIndex + players_data[lotteryNumber][currentPlayer].amount_bet){
                winner = payable(currentPlayer);
            }
            amountIndex += players_data[lotteryNumber][currentPlayer].amount_bet;
        }
        
        uint amount = address(this).balance;
        winner.transfer(amount);

        lotteryNumber++;
        totalAmount = 0;
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

    //Return players of a lottery round
    function getLotteryPlayers(uint lottery_round) public view returns (Player[] memory) {
        uint playerCount = players[lottery_round].length;
        Player[] memory list = new Player[](playerCount);

        for (uint i = 0; i < playerCount; i++) {
            address currentPlayer = players[lottery_round][i];
            Player storage p = players_data[lottery_round][currentPlayer];
            list[i] = p;
        }
        
        return list;
    }

    //Return current lottery players
    function getCurrentLotteryPlayers() public view returns (Player[] memory) {
        return getLotteryPlayers(lotteryNumber);
    }

    //Generate a random number with modulo
    function randMod(uint _modulus)private returns(uint)
    {
        randNonce++;
        return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % _modulus;
    }

    //Control access in a require function
    modifier restricted() {
        require(msg.sender == owner);
        _;
    }
}