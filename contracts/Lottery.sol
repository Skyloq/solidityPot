pragma solidity ^0.8.3;

contract Lottery {

    struct Ticket {
        address buyer;
        uint value;
    }

    address payable owner;
    uint public montantTotal;
    Ticket[] public tickets;

    constructor() {
        owner = payable(msg.sender);
        montantTotal = 0;
    }

    function buyTicket(uint montant) public payable {
        require(montant > 0, "Le montant ajoute doit etre superieur a zero");

        Ticket memory newTicket = Ticket({
            buyer: msg.sender,
            value: montant
        });

        tickets.push(newTicket);

        montantTotal += montant;
    }

    function winTicket(uint montant) public payable {
        require(msg.sender == owner, "Seul le proprietaire peut retirer des fonds");
        require(montant <= montantTotal, "Le montant demande est superieur au montant total de la cagnotte");

        montantTotal -= montant;
        //ça marche pas
        owner.transfer(montant);
    }
}