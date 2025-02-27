// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SimpleStorage {
    uint256 num;

    function set(uint256 n) public {
        num = n;
    }

    function get() public view returns (uint256) {
        return num;
    }
}