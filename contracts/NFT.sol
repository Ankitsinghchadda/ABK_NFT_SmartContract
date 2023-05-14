// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    event Minted(uint256 indexed tokenId, address indexed to, string indexed tokenURI);

    /// @notice Platform fee
    uint256 public platformFee;

    /// @notice Platform fee receipient
    address payable public feeReceipient;

    constructor(string memory _name, string memory _symbol, uint256 _platformFee, address payable _feeReceipient) ERC721(_name, _symbol) {
        platformFee = _platformFee;
        feeReceipient = _feeReceipient;
    }

    function mint(string memory tokenURI) external payable
    {
        require(msg.value >= platformFee, "Insufficient funds to mint.");
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        _tokenIds.increment();

        (bool success,) = feeReceipient.call{value : msg.value}("");
        require(success, "Transfer failed");
        emit Minted(newItemId, msg.sender, tokenURI);
    }

    function getTokenCounter() public view returns (uint256) {
        return _tokenIds.current();
    }

    /**
     @notice Method for updating platform fee
     @dev Only admin
     @param _platformFee uint256 the platform fee to set
     */
    function updatePlatformFee(uint256 _platformFee) external onlyOwner {
        platformFee = _platformFee;
    }

    /**
     @notice Method for updating platform fee address
     @dev Only admin
     @param _feeReceipient payable address the address to sends the funds to
     */
    function updateFeeRecipient(address payable _feeReceipient)
        external
        onlyOwner
    {
        feeReceipient = _feeReceipient;
    }
}
