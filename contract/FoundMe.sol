// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


//1、创建一个收款函数
//2、记录投资人并查看
//3、在锁定期内，达到目标值，生产商可以提款
//4、在锁定期内，没有达到目标值，投资人在锁定期以后退款
contract FundMe {

    mapping(address => uint256) public fundersToAmount;

    uint256 MINIMUM_VALUE = 1 * 10 ** 18;

    AggregatorV3Interface internal dataFeed;

    constructor() {
        dataFeed = AggregatorV3Interface(0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43);
    }

    function fund() external payable {
        require(msg.value >= MINIMUM_VALUE, "Send more ETH, At least 1 ETH");
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

}