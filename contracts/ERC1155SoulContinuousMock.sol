// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;


import "./ERC1155SoulContinuous.sol";


contract ERC1155SoulContinuousMock is ERC1155SoulContinuous {

    function mint(
        address[] calldata tos
    ) external {
        _mint(tos);
    }

    function uri(uint256 id) public view override returns (string memory) {
        return "";
    }

    function batchSize() public view virtual returns (uint256) {
        return _batchSize();
    }

    function nextTokenId() public view virtual returns (uint256) {
        return _nextTokenId();
    }
}

contract ERC1155SoulContinuousMockStartTokenId is ERC1155SoulContinuousMock {
    uint256 immutable _start;

    constructor(uint256 startTokenId) {
        _start = startTokenId;
    }

    function _startTokenId() override internal view returns (uint256) {
        return _start;
    }
}
