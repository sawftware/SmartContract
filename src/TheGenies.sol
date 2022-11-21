// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721A.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract TheGenies is ERC721A, Ownable, ReentrancyGuard{
    uint256 public constant maxSupply = 7777;
    uint public _price = 0.05 ether;
    uint256 public maxBuyPerTx = 5;
    bool public paused;

    constructor(string memory _notRevealedUri) ERC721A("TheGenies", "GENIE", _notRevealedUri) {
        paused = true;
    }

    // Read the price
    function getPrice() view public returns (uint256){
        return _price;
    }

    // Write a new price
    function setPrice(uint256 _newPrice) external onlyOwner() {
        _price = _newPrice;
    }

    // Reveal the NFTs
    function setRevealed() external onlyOwner() {
        _setRevealed();
    }
    
    // Mint
    function mint(uint256 _mintAmount) external payable mintCompliance(_mintAmount) {
        require(paused == false, "Must Unpause");
        require(msg.value >= _price * _mintAmount, "Not enough funds");
        _safeMint(msg.sender, _mintAmount);
    }

    modifier mintCompliance(uint256 _mintAmount) {
    require(_mintAmount > 0 && _mintAmount <= maxBuyPerTx, "Invalid buy amount");
    require(totalSupply() + _mintAmount <= maxSupply, "Sold out!");
    _;
    }

    // Mint for Dev
    function devMint(uint256 _qty) external onlyOwner {
        require(paused == true, "Must paused");
        _safeMint(msg.sender, _qty);
    }

    // Withdraw ETH
    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // Metadata URI
    string private _baseTokenURI;
    
    // Read Metadata URI
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }
    // Write Metadata URI
    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    // Pause & Unpause minting
    function setPaused(bool _paused) external onlyOwner {
    paused = _paused;
    }
}