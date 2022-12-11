// SPDX-License-Identifier: MIT
// Creator: Ctor Lab (https://ctor.xyz)

pragma solidity ^0.8.0;


interface IIsOwnerOf {

    function isOwnerOf(address account, uint256 id) external view returns(bool);

}