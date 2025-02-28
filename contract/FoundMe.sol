// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


//1、创建一个收款函数
//2、记录投资人并查看
//3、在锁定期内，达到目标值，生产商可以提款
//4、在锁定期内，没有达到目标值，投资人在锁定期以后退款
contract FundMe {

    mapping(address => uint256) public fundersToAmount;

    uint256 MINIMUM_VALUE = 100 * 10 ** 18;

    AggregatorV3Interface internal dataFeed;

    //目标值
    uint256 constant TARGET = 1000 * 10 ** 18;

    //合约拥有者
    address public owner;

    //合约部署时间
    uint256 deploymentTimestamp;
    //锁定期
    uint256 lockTime;

    constructor(uint256 _lockTime) {
        dataFeed = AggregatorV3Interface(0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43);
        owner = msg.sender;
        deploymentTimestamp = block.timestamp;
        lockTime = _lockTime;
    }

    /**
     * 向合约发送Eth
     */
    function fund() external payable {
        require(convertEthToUsd(msg.value) >= MINIMUM_VALUE, "Send more ETH, At least 1 ETH");
        require(block.timestamp < deploymentTimestamp + lockTime, "window is closed!");
        fundersToAmount[msg.sender] = msg.value;
    }

    /**
     * Returns the latest answer.
     */
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function convertEthToUsd(uint256 ethAmount) internal view returns(uint256) {
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        return ethAmount * ethPrice / (10 ** 8);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    /**
     * 提款，三种方式：transfer、send、call，官方推荐call功能更强大
     */
    function getFund() external windowClosed onlyOwner {
        require(convertEthToUsd(address(this).balance) >= TARGET, "TARGET is not reached!");
        //transfer: transfer ETH and revert if tx failed
        //payable(owner).transfer(address(this).balance);

        //send: transfer ETH and return false if failed
        //bool success = payable(owner).send(address(this).balance);
        //require(success, "Payment Failed!");

        //call: transfer ETH with data return value of function and bool 
        bool success;
        (success, /*returnData*/) = payable(owner).call{value: address(this).balance}("");
        require(success, "transfer tx failed");
        fundersToAmount[msg.sender] = 0;
    }


    /**
     * 退款
     */
    function refund() external windowClosed {
        require(convertEthToUsd(address(this).balance) < TARGET, "TARGET is reached!");
        require(fundersToAmount[msg.sender] != 0, "there is no fund for you");
        bool success;
        (success, /*returnData*/) = payable(msg.sender).call{value: fundersToAmount[msg.sender]}("");
        require(success, "transfer tx failed");
        fundersToAmount[msg.sender] = 0;
    }

    /*
     * _;放在后面时，以refund函数为例，先执行windowClosed的校验，通过后才执行refund；
     * 放在前面，先执行refund，后执行windowClosed的校验
     */
    modifier windowClosed() {
        require(block.timestamp >= deploymentTimestamp + lockTime, "window is not closed!");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "this function can only be called by owner");
        _;
    }

}