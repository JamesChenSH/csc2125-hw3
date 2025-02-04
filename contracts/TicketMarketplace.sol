// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ITicketNFT} from "./interfaces/ITicketNFT.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {TicketNFT} from "./TicketNFT.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol"; 
import {ITicketMarketplace} from "./interfaces/ITicketMarketplace.sol";
import "hardhat/console.sol";

contract TicketMarketplace is ITicketMarketplace {
    // your code goes here (you can do it!)
    address public ERC20Address;
    TicketNFT public nftContract;
    address public owner;
    
    uint128 public currentEventId = 0;

    constructor(address _sampleCoinAddress) {
        ERC20Address = _sampleCoinAddress;
        owner = msg.sender;
        nftContract = new TicketNFT("", address(this));
    }

    struct Event {
        uint128 maxTickets;
        uint128 nextTicketToSell;
        uint256 pricePerTicket;
        uint256 pricePerTicketERC20;
    }

    mapping(uint128 => Event) public events;

    function createEvent(uint128 maxTickets, uint256 pricePerTicket, uint256 pricePerTicketERC20) public override {
        if (msg.sender != owner) {
            revert("Unauthorized access");
        }
        events[currentEventId] = Event(maxTickets, 0, pricePerTicket, pricePerTicketERC20);
        emit EventCreated(currentEventId, maxTickets, pricePerTicket, pricePerTicketERC20);
        currentEventId++;
    }

    function setMaxTicketsForEvent(uint128 eventId, uint128 newMaxTickets) public override{
        if (owner != msg.sender) {
            revert("Unauthorized access");
        } else if (events[eventId].maxTickets >= newMaxTickets) {
            revert("The new number of max tickets is too small!");
        }
        events[eventId].maxTickets = newMaxTickets;
        emit MaxTicketsUpdate(eventId, newMaxTickets);
    }

    function setPriceForTicketETH(uint128 eventId, uint256 price) public override {
        if (owner != msg.sender) {
            revert("Unauthorized access");
        }
        events[eventId].pricePerTicket = price;
        emit PriceUpdate(eventId, price, "ETH");
    }

    function setPriceForTicketERC20(uint128 eventId, uint256 price) public override{
        if (owner != msg.sender) {
            revert("Unauthorized access");
        }
        events[eventId].pricePerTicketERC20 = price;
        emit PriceUpdate(eventId, price, "ERC20");
    }

    function buyTickets(uint128 eventId, uint128 ticketCount) payable public override{

        unchecked {
            if (ticketCount * events[eventId].pricePerTicket / events[eventId].pricePerTicket != ticketCount) {
                revert("Overflow happened while calculating the total price of tickets. Try buying smaller number of tickets.");
            }  
        }
        if (events[eventId].nextTicketToSell + ticketCount > events[eventId].maxTickets) {
            revert("We don't have that many tickets left to sell!");
        } else if (msg.value < events[eventId].pricePerTicket * ticketCount) {
            revert("Not enough funds supplied to buy the specified number of tickets.");
        }

        for (uint128 i = 0; i < ticketCount; i++) {
            uint256 nftId = eventId;
            nftId = (nftId << 128) + events[eventId].nextTicketToSell;
            events[eventId].nextTicketToSell++;
            nftContract.mintFromMarketPlace(msg.sender, nftId);
        }

        emit TicketsBought(eventId, ticketCount, "ETH");
    }

    function buyTicketsERC20(uint128 eventId, uint128 ticketCount) public override{

        unchecked {
            if (ticketCount * events[eventId].pricePerTicketERC20 / events[eventId].pricePerTicketERC20 != ticketCount) {
                revert("Overflow happened while calculating the total price of tickets. Try buying smaller number of tickets.");
            }  
        }
        if (events[eventId].nextTicketToSell + ticketCount > events[eventId].maxTickets) {
            revert("We don't have that many tickets left to sell!");
        } else if (IERC20(ERC20Address).balanceOf(msg.sender) < events[eventId].pricePerTicketERC20 * ticketCount) {
            revert("You don't have enough ERC20 tokens to buy these tickets!");
        }

        IERC20(ERC20Address).transferFrom(msg.sender, address(this), events[eventId].pricePerTicketERC20 * ticketCount);

        for (uint128 i = 0; i < ticketCount; i++) {
            uint256 nftId = eventId;
            nftId = (nftId << 128) + events[eventId].nextTicketToSell;
            events[eventId].nextTicketToSell++;
            nftContract.mintFromMarketPlace(msg.sender, nftId);
        }

        emit TicketsBought(eventId, ticketCount, "ERC20");

    }

    function setERC20Address(address newERC20Address) public override{
        if (owner != msg.sender) {
            revert("Unauthorized access");
        }
        ERC20Address = newERC20Address;
        emit ERC20AddressUpdate(newERC20Address);
    }
}