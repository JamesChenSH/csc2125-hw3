// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ITicketNFT} from "./interfaces/ITicketNFT.sol";

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract TicketNFT is ERC1155, ITicketNFT {
    // your code goes here (you can do it!)

    // Store owner of contract
    address public owner;

    constructor (string memory _url, address _owner) ERC1155(_url) {
        // Init Owner
        owner = _owner;
    }

    function mintFromMarketPlace(address to, uint256 nftId) external {
        // Mint 1 NFT to the address
        _mint(to, nftId, 1, "");
    }

}