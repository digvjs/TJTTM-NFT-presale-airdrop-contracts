// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TJTTM is ERC721Enumerable, Ownable {
    using Strings for uint256;
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private tokenIdsCounter;

    enum SaleStage { sale1, sale2, other }     // ids are 0, 1, 2

    SaleStage public saleStage = SaleStage.other;     // Default to other
    mapping(uint => uint256) numTokensSoldByStage;      // Number of tokens sold by each stage
    mapping(uint => uint256) maxCapByStage;             // Max tokens that can be minted in sale stage

    string public baseURI;
    string public baseExtension = ".json";
    uint256 public cost = 0.09 ether;
    uint256 public maxSupply = 10000;
    uint256 public maxMintAmount = 20;
    bool public paused = true;

    constructor(
        string memory _initBaseURI
    ) ERC721("Tigers Journey To The Moon", "TJTTM") {
        setBaseURI(_initBaseURI);

        // Initialise max cap for sale stages
        maxCapByStage[uint(SaleStage.sale1)] = 1000;
        maxCapByStage[uint(SaleStage.sale2)] = 1000;
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function getMaxCapForStage(uint _stage) public view returns (uint256) {
        return maxCapByStage[_stage];
    }

    // public
    function mint(address _to, uint256 _mintAmount) public payable {
        uint256 supply = totalSupply();
        require(!paused, "Contract paused!");
        require(_to != address(0), "_to address cannot be dead address!");
        require(_mintAmount > 0);
        require(_mintAmount <= maxMintAmount, "_mintAmount exceeds max maxMintAmount!");
        require(supply.add(_mintAmount) <= maxSupply, "MaxSupply exceeding!");

        if (saleStage != SaleStage.other) {
            uint256 _totalSell = numTokensSoldByStage[uint(saleStage)].add(_mintAmount);
            require(_totalSell <= maxCapByStage[uint(saleStage)], "_mintAmount exceeding max cap for current sale!");
        }

        if (msg.sender != owner()) {
            require(msg.value >= cost.mul(_mintAmount), "Not enough ethers sent to mint NFTs!");
        }

        for (uint256 i = 1; i <= _mintAmount; i++) {
            tokenIdsCounter.increment();
            _safeMint(_to, tokenIdsCounter.current());
        }

        // Update token sold count
        numTokensSoldByStage[uint(saleStage)] = numTokensSoldByStage[uint(saleStage)].add(_mintAmount);
    }

    /**
     * @dev get tokenIds of _account address
     */
    function walletOfOwner(address _account)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_account);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_account, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();

        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension)
                )
                : "";
    }

    //only owner
    function setCost(uint256 _newCost) public onlyOwner() {
        cost = _newCost;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner() {
        maxMintAmount = _newmaxMintAmount;
    }

    function setmaxCapForStage(uint _stage, uint256 _maxCap) public onlyOwner() {
        maxCapByStage[_stage] = _maxCap;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    /**
    * @dev Allows admin to update the sale stage
    * @param _stage sale stage
    */
    function setSaleStage(uint _stage) public onlyOwner {
        if(uint(SaleStage.sale1) == _stage) {
            saleStage = SaleStage.sale1;
            cost = 0.09 ether;
        } else if (uint(SaleStage.sale2) == _stage) {
            saleStage = SaleStage.sale2;
            cost = 1.23 ether;
        } else {
            saleStage = SaleStage.other;
        }
    }

    /**
    * @dev Burn NFT by giving tokenId.
    * @dev Able to burn only if owner of NFT or approved to NFT
    */
    function burn(uint256 tokenId) public onlyOwner {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721Burnable: caller is not owner nor approved"
        );

        _burn(tokenId);
    }

    /**
     * @dev Withdraw ethers available on contract to the callers address
     */
    function withdraw() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }
}