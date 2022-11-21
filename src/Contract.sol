// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721A.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Contract is ERC721A, Ownable, ReentrancyGuard{
    
    uint256 public constant maxSupply = 7777;
    uint public _price = 0.05 ether;
    uint256 public maxBuyPerTx = 5;
    bool public _paused;
    string private _baseTokenURI;

    constructor(string memory name, string memory symbol, string memory notRevealedUri) ERC721A(name, symbol, notRevealedUri) {
        _paused = true;
    }

    function getPrice() view public returns (uint256) {
        return _price;
    }

    function setPrice(uint256 price) external onlyOwner() {
        _price = price;
    }

    function setRevealed() external onlyOwner() {
        _setRevealed();
    }
    
    function mint(uint256 mintAmount) external payable mintCompliance(mintAmount) {
        require(_paused == false, "Must be unpaused");
        require(msg.value >= _price * mintAmount, "Not enough funds");
        _safeMint(msg.sender, mintAmount);
    }

    modifier mintCompliance(uint256 mintAmount) {
        require(mintAmount > 0 && mintAmount <= maxBuyPerTx, "Invalid buy amount");
        require(totalSupply() + mintAmount <= maxSupply, "Sold out!");
        _;
    }

    function devMint(uint256 qty) external onlyOwner {
        require(_paused == true, "Must be paused");
        _safeMint(msg.sender, qty);
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function setPaused(bool paused) external onlyOwner {
        _paused = paused;
    }
}