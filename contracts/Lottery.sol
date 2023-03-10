// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address public manager;
    address payable[] public players;

    event NewPlayer(address player);
    event Winner(address winner, uint amount);

    constructor() {
        manager = msg.sender;
    }

    function enter() public payable {
        require(msg.value > 0.0001 ether);
        players.push(payable(msg.sender));
        emit NewPlayer(msg.sender);
    }

    function pickWinner() public restricted {
        require(players.length > 0);
        uint index = random() % players.length;
        address payable winner = players[index];
        uint amount = address(this).balance;
        winner.transfer(amount);
        players = new address payable[](0);
        emit Winner(winner, amount);
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
}
