// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Token} from "./Token.sol";
import {ECDSA} from "solady/utils/ECDSA.sol";

contract WeekPool {
    uint256 private _week;
    uint256 private _totalPoints;
    Token private _token;
    uint256 private _tokens;

    address private _signer;

    mapping(uint256 => bool) _claimed;

    bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant SOME_TYPE_HASH = keccak256("BaselineRequest(uint256 vehicleId,address owner,uint256 week,uint256 points)");
    

    constructor(address token, uint256 week, uint256 totalPoints, address signer, uint256 tokens) {
        _token = Token(token);
        _week = week;
        _totalPoints = totalPoints;
        _signer = signer;
        _tokens = tokens;
    }

    function claim(bytes calldata data) external {
        bytes32 DOMAIN_SEPARATOR = keccak256(abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            keccak256(bytes("Baseline")),
            keccak256(bytes("1")),
            block.chainid,
            address(0x7e41893AbDc4E7416b00109b29f17AB74Ba312Cf)
        ));

        (uint256 vehicleId, address owner, uint256 week, uint256 points, bytes memory signature) =  abi.decode(data, (uint256, address, uint256, uint256, bytes));

        require(!_claimed[vehicleId], "Already claimed");
        require(_week == week, "Wrong week");

        bytes32 structHash = keccak256(abi.encode(SOME_TYPE_HASH, vehicleId, owner, week, points));
        bytes32 fullHash = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));

        require(ECDSA.recover(fullHash, signature) == _signer, "Wrong signer");

        _claimed[vehicleId] = true;

       require(_token.transfer(owner, (_tokens * points) / _totalPoints), "Transfer failed");
    }
}
