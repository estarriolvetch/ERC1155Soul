# ERC1155Soul

[![Test](https://github.com/ctor-lab/ERC1155Soul/actions/workflows/node.js.yml/badge.svg)](https://github.com/ctor-lab/ERC1155Soul/actions/workflows/node.js.yml)
[![Publish Package to npmjs](https://github.com/ctor-lab/ERC1155Soul/actions/workflows/deploy_npm.yml/badge.svg)](https://github.com/ctor-lab/ERC1155Soul/actions/workflows/deploy_npm.yml)
[![npm](https://img.shields.io/npm/v/erc1155soul)](https://www.npmjs.com/package/erc1155soul)

An ERC1155 soulbound token (SBT) impelementation with ultralow gas usage.

While minting 500 tokens, each SBT costs about ~7500 gas only. This is rouhly 4x ~ 5x lower than using the conventional ERC1155 implementations.

In addition, each SBT has its unique token ID. Namely, you will not see the SBTs overlapped with each other on the Opensea, and it is possible to give each SBT its unique metadata.

There are two varialnts, `ERC1155Soul` and `ERC1155SoulContinuous`. The token IDs of `ERC1155SoulContinuous` is always continuous. However, `ERC1155Soul` uses less gas. See [benchmark](#benchmark) for a more detailed comparision.

## How it works

`ERC1155Soul` uses two facts to achieve the ultralow gas usage:

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
## Benchmark

### ERC1155Soul
|# of token |total gas|gas per token|
|---|---|---|
| 1 | 84186 | 84186 |
| 2 | 91270 | 45635 |
| 4 | 105432 | 26358 |
| 8 | 133762 | 16720 |
| 16 | 190417 | 11901 |
| 32 | 303726 | 9491 |
| 64 | 530352 | 8286 |
| 128 | 983619 | 7684 |
| 256 | 1890221 | 7383 |
| 500 | 3618685 | 7237 |
### ERC1155SoulContinuous
|# of token  |total gas|gas per token|
|---|---|---|
| 1 | 128546 | 128546 |
| 2 | 135627 | 67813 |
| 4 | 149783 | 37445 |
| 8 | 178101 | 22262 |
| 16 | 234732 | 14670 |
| 32 | 347993 | 10874 |
| 64 | 574523 | 8976 |
| 128 | 1027598 | 8028 |
| 256 | 1933816 | 7553 |
| 500 | 3661548 | 7323 |
