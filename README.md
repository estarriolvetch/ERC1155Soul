# ERC1155Soul

[![Test](https://github.com/ctor-lab/ERC1155Soul/actions/workflows/node.js.yml/badge.svg)](https://github.com/ctor-lab/ERC1155Soul/actions/workflows/node.js.yml)
[![Publish Package to npmjs](https://github.com/ctor-lab/ERC1155Soul/actions/workflows/deploy_npm.yml/badge.svg)](https://github.com/ctor-lab/ERC1155Soul/actions/workflows/deploy_npm.yml)

An ERC1155 soulbound token (SBT) impelementation with ultralow gas usage.

While minting 500 tokens, each SBT costs about ~7500 gas only.

In addition, each SBT has its unique token ID. Namely, you will not see the SBTs overlapped with each other on the Opensea, and it is possible to give each SBT its unique metadata.

## How it works

`ERC1155Soul` uses the two facts to achieve the ultralow gas usage:

* Storing the data within the smart contract is much cheaper (uses less gas) than in the storage.
* A smart contract can create another smart contract.

When `ERC1155Soul` SBT is minted (airdroped), instead of storing the ownership information to the storage like most of the NFT implementation, it creates another smart contract. The ownership information is hardcoded inside the created smart contract. The smart contract is in general immutable, but its immutablility perfectly fits the application of SBT.

## Installaion
### npm
```
npm install erc1155soul
```
### yarn
```
yarn add erc1155soul
```

## Usage
```solidity
pragma solidity >=0.8.0;

import "erc1155soul/contracts/ERC1155Soul.sol";

contract MySoulBoundToken is ERC1155Soul {

    /// @param tos are the array of the acconts to receive the SBTs.
    function mint(
        address[] calldata tos
    ) external {
        _mint(tos);
    }

    function uri(uint256 id) public view override returns (string memory) {
        return "https://my-soubound-metadata-uri/{id}";
    }

}
```
