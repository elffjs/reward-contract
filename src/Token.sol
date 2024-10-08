// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface Token {
    function transfer(address to, uint256 value) external returns (bool);
}