// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;


import "./ERC1155Soul.sol";


contract ERC1155SoulMock is ERC1155Soul {

    function mint(
        address[] calldata tos
    ) external {
        _mint(tos);
    }

    function uri(uint256 id) public view override returns (string memory) {
        return "";
    }
}