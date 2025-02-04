// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ITicketNFT} from "./interfaces/ITicketNFT.sol";

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract TicketNFT is ERC1155, ITicketNFT {
    // your code goes here (you can do it!)
    uint256 private ID = 0;
    address public owner;

    constructor (uint256 eventID, uint256 seatID) ERC1155("") {
        ID = (eventID << 128) | seatID;
        owner = msg.sender;
        _mint(msg.sender, ID, 1, "");
    }

    function mintFromMarketPlace(address to, uint256 nftId) public {
        _mint(to, nftId, 1, "");
    }
}