// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Oleksirium is ERC20, Ownable {
    AggregatorV3Interface internal priceFeed; // ETH/USD Contract: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419

    uint256 public tokenPrice;

    event PriceUpdated(uint256 newPrice);
    event TokenPurchased(address indexed buyer, uint256 amount, uint256 cost);
    event ChangeReturned(address indexed buyer, uint256 amount);
    
    constructor(string memory name_, string memory symbol_, address priceFeed_) ERC20(name_, symbol_) {
        priceFeed = AggregatorV3Interface(priceFeed_);
    }

    function setTokenPrice(uint256 newPrice_) external onlyOwner {
        tokenPrice = newPrice_;
        emit PriceUpdated(newPrice_);
    }

    function getEthPrice() public view returns (uint256) {
        int256 EthPrice;
        (,EthPrice,,,) = priceFeed.latestRoundData();
        
        return uint256(EthPrice);
    }

    function getUsdPrice(uint256 tokenAmount_) public view returns (uint256) {
        uint256 UsdPrice;
        UsdPrice = tokenAmount_ * tokenPrice;

        return UsdPrice;
    }

    function getTokenPriceInEth(uint256 tokenAmount_) public view returns (uint256) {
        uint256 tokenPriceInEth;
        tokenPriceInEth = getUsdPrice(tokenAmount_) / getEthPrice();

        return tokenPriceInEth;
    }

    function buyToken(uint256 tokenAmount_) public payable {
        require(tokenPrice > 0, "Price not set");
        require(tokenAmount_ > 0, "Invalid amount");
        require(msg.value * getEthPrice() >= getUsdPrice(tokenAmount_), "Insufficient balance");
        
        uint256 change;
        change = msg.value - getTokenPriceInEth(tokenAmount_);

        if (change > 0) {
            payable(msg.sender).transfer(change);

            emit ChangeReturned(msg.sender, change);
        }

        _mint(msg.sender, tokenAmount_);

        emit TokenPurchased(msg.sender, tokenAmount_, msg.value - change);
    }
}

// decimals оракла і мого токена
// деплой
// веріфай
// tests