// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;


import "@0xsequence/sstore2/contracts/SSTORE2Map.sol";


abstract contract ERC1155Soul {

    uint256 private _batchIndex;

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 amount
    );

    error NotImplemented();
    error BalanceQueryForZeroAddress();
    error InputLengthMistmatch();


    function uri(uint256 id) public view virtual returns (string memory);

    function _startTokenId() internal pure virtual returns (uint256) {
        return 0;
    }

    function _batchSize() internal pure virtual returns (uint256) {
        return 500;
    }

    function _nextTokenId() internal view virtual returns (uint256) {
        return _startTokenId() + _batchIndex * _batchSize();
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        revert NotImplemented();
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) public virtual {
        revert NotImplemented();
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) public virtual {
        revert NotImplemented();
    }


    function balanceOf(address account, uint256 id) public view virtual returns (uint256) {
        if(account == address(0)) {
            revert BalanceQueryForZeroAddress();
        }
        uint256 batch = (id - _startTokenId()) / _batchSize();
        uint256 offset = ((id - _startTokenId()) % _batchSize()) * 20;

        address owner = abi.decode(
            SSTORE2Map.read(bytes32(batch), offset, offset + 20),
            (address)
        );

        if(account == owner) {
            return 1;
        } else {
            return 0;
        }   
    }

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        public
        view
        virtual
        returns (uint256[] memory balances)
    {
        if(accounts.length != ids.length) {
            revert InputLengthMistmatch();
        }

        uint256[] memory batchBalances = new uint256[](accounts.length);
        unchecked {
            for (uint256 i = 0; i < accounts.length; ++i) {
                batchBalances[i] = balanceOf(accounts[i], ids[i]);
            }   
        }
        return batchBalances;
        
    }


    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0xd9b67a26 || // ERC165 Interface ID for ERC1155
            interfaceId == 0x0e89341c; // ERC165 Interface ID for ERC1155MetadataURI
    }


    function _mint(
        address[] memory tos
    ) internal virtual {
        require(tos.length <= _batchSize());
        SSTORE2Map.write(
            bytes32(_batchIndex),
            abi.encode(tos)
        );
        for (uint256 i = 0; i < tos.length; i++) {
            emit TransferSingle(msg.sender, address(0), tos[i], _nextTokenId() + 1, 1);
        }
        _batchIndex++;
    }
}
