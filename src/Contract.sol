// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721A.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Contract is ERC721A, Ownable, ReentrancyGuard{
    uint256 public constant maxSupply = 7777;
    uint public _price = 0.05 ether;
    uint256 public maxBuyPerTx = 5;
    bool public paused;
    string private _baseTokenURI;

    constructor(string memory name, string memory symbol, string memory notRevealedUri) ERC721A(name, symbol, notRevealedUri) {
        paused = true;
    }

    function getPrice() view public returns (uint256){
        return _price;
    }

    function setPrice(uint256 _newPrice) external onlyOwner() {
        _price = _newPrice;
    }

    function setRevealed() external onlyOwner() {
        _setRevealed();
    }
    
    function mint(uint256 _mintAmount) external payable mintCompliance(_mintAmount) {
        require(paused == false, "Must be unpaused");
        require(msg.value >= _price * _mintAmount, "Not enough funds");
        _safeMint(msg.sender, _mintAmount);
    }

    modifier mintCompliance(uint256 _mintAmount) {
        require(_mintAmount > 0 && _mintAmount <= maxBuyPerTx, "Invalid buy amount");
        require(totalSupply() + _mintAmount <= maxSupply, "Sold out!");
        _;
    }

    function devMint(uint256 _qty) external onlyOwner {
        require(paused == true, "Must be paused");
        _safeMint(msg.sender, _qty);
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

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }
}