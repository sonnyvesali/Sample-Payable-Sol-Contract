// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract GetPaid {
    address payable public owner;
    address[] public funders;

    constructor() {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    mapping(address => uint256) addressToDollarAmt;

    function getThePrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x9326BFA02ADD2366b30bacB125260Af641031331
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    function ConvertPriceToUSD() public view returns (uint256) {
        uint256 currPrice = getThePrice();
        return (currPrice / 10**8);
    }

    function deposit() public payable {
        uint256 minimumAmt = 100 * 10**18;
        require(msg.value >= minimumAmt, "Deposit more fool");
        addressToDollarAmt[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function withdraw() public payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);

        for (uint256 funderI = 0; funderI < funders.length; funderI++) {
            address withdrawlAddy = funders[funderI];
            addressToDollarAmt[withdrawlAddy] = 0;
        }
        funders = new address[](0);
    }
}
