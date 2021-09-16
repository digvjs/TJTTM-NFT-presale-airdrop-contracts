// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
* Tigers Journey To The Moon Airdrop Contract
*/
contract TJTTMAirdrop is Ownable {
    struct Airdrop {
        address nft;
        uint id;
    }

    uint public nextAirdropId;
    bool public paused = true;

    mapping(uint => Airdrop) public airdrops;   // All NFT added for airdrop
    mapping(address => bool) public recipients; // List of accounts able to claim NFT

    /**
    * constructor
    */
    constructor() {
        //
    }

    /**
    * @dev Add airdrops, transfers the tokens from msg.sender to airdrop contract address.
    * @param _airdrops array [
    *       [ <contract_address>, <token_id_1> ],
    *       [ <contract_address>, <token_id_2> ],
    * ]
    */
    function addAirdrops(Airdrop[] memory _airdrops) public onlyOwner {
        uint _nextAirdropId = nextAirdropId;
        for (uint i = 0; i < _airdrops.length; i++) {
            airdrops[_nextAirdropId] = _airdrops[i];
            IERC721(_airdrops[i].nft).transferFrom(
                msg.sender,
                address(this),
                _airdrops[i].id
            );
            _nextAirdropId++;
        }
    }

    /**
    * @dev Adds to the list of accounts able to claim NFT airdrop
    * @param _recipients array [
    *   "<address_1>",
    *   "<address_2>"
    * ]
    */
    function addRecipients(address[] memory _recipients) public onlyOwner {
        for (uint i = 0; i < _recipients.length; i++) {
            recipients[_recipients[i]] = true;
        }
    }

    /**
    * @dev This removes recepients from list
    * @param _recipients array [
    *   "<address_1>",
    *   "<address_2>"
    * ]
    */
    function removeRecipients(address[] memory _recipients) public onlyOwner {
        for (uint i = 0; i < _recipients.length; i++) {
            recipients[_recipients[i]] = false;
        }
    }

    /**
     * @dev Pause contract from claim
     */
    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    /**
    * @dev Recipients can claim only 1 NFT
    * @dev NFT will be transfered to the caller of this function
    */
    function claim() external {
        require(!paused, "Contract paused!");
        require(recipients[msg.sender] == true, 'recipient not registered');
        recipients[msg.sender] = false;
        Airdrop storage airdrop = airdrops[nextAirdropId];
        IERC721(airdrop.nft).transferFrom(address(this), msg.sender, airdrop.id);
        nextAirdropId++;
    }
}