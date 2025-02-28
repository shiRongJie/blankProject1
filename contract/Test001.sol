// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

//继承，抽象，重载
abstract contract Parent {
    uint256 public num;

    function addOne() public {
        num++;
    }

    function addTwo() public virtual;
}

contract Child is Parent {

    function addTwo() public override {
        num = num + 2;
    }

    function addThree() public {
        num = num + 3;
    }
}