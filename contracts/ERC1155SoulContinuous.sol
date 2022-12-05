// SPDX-License-Identifier: MIT
// Creator: Ctor Lab (https://ctor.xyz)

pragma solidity >=0.8.0;

import "solmate/src/utils/SSTORE2.sol";
import "solidity-bits/contracts/BitMaps.sol";

/**
 * @title ERC1155SoulContinuous
 * 
 * @notice ERC1155Soul is an ERC1155 soulbound token implementaion.
 *         It is designed to be extremely gas efficent when minting to multiple addresses in a single transaction.
 *         
 *         Each token ID of this implementation are unique, and the IDs are consecutive.
 *         
 *         If having continuous token IDs between minting batches is not required, 
 *         one may consider using ERC1155Soul to save more gas.
 *
 */
abstract contract ERC1155SoulContinuous {
    using BitMaps for BitMaps.BitMap;
    uint256 private constant ADDRESS_SIZE = 20;

    uint256 private __totalMinted;
    BitMaps.BitMap private _batchHead;
    mapping(uint256 => address) private _batchDataStorage;

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
    error ExceedBatchSize();
    error MintZeroAmount();


    function uri(uint256 id) public view virtual returns (string memory);

    function _startTokenId() internal view virtual returns (uint256) {
        return 0;
    }

    function _batchSize() internal view virtual returns (uint256) {
        return 500;
    }

    function _nextTokenId() internal view virtual returns (uint256) {
        return _startTokenId() + __totalMinted;
    }

    function _totalMinted() internal view virtual returns (uint256) {
        return __totalMinted;
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

    function batchHead(uint256 id) public view virtual returns (uint256) {
        return _batchHead.scanForward(id);
    }


    function balanceOf(address account, uint256 id) public view virtual returns (uint256) {
        if(account == address(0)) {
            revert BalanceQueryForZeroAddress();
        }

        if(id >= _nextTokenId()) {
            return 0;
        }

        if(id < _startTokenId()) {
            return 0;
        }

        if(!_batchHead.get(_startTokenId())) {
            return 0;
        }
        
        uint256 batchHeadId = _batchHead.scanForward(id);
        uint256 start = (id - batchHeadId) * ADDRESS_SIZE;
        uint256 end = start + ADDRESS_SIZE;
        address dataStorage = _batchDataStorage[batchHeadId];


        bytes memory data = SSTORE2.read(
            dataStorage
            , start, end
        );

        address owner;
        assembly {
            owner := mload(add(data, ADDRESS_SIZE))
        } 
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

    /// @dev Mint tokens to multiple accounts.
    /// @param tos Accounts to receive the tokens.
    function _mint(
        address[] memory tos
    ) internal virtual {
        if(tos.length == 0) {
            revert MintZeroAmount();
        }

        uint256 next = _nextTokenId();
        uint256 numToMint = tos.length;

        if(tos.length > _batchSize()) {
            revert ExceedBatchSize();
        }

        bytes memory buffer;
        assembly {
            buffer := tos // cast address[] to bytes
        }

        unchecked {
            require(next + numToMint > next); //no overflow  
            for (uint256 i = 0; i < numToMint; i++) {
                address to = tos[i];

                // remove the zeros between addresses in the array, so we won't wasting gas on storing the zeros.
                bytes32 toBytes32 = bytes32(bytes20(to));
                assembly {  
                    mstore(add(add(buffer, mul(i, ADDRESS_SIZE)),32), toBytes32)
                } 
                    
                emit TransferSingle(msg.sender, address(0), to, next + i, 1);
            }    
        }
        
        uint256 bufferLength = numToMint * ADDRESS_SIZE;
        assembly {  
            // fill in the length of the buffer size.
            mstore(buffer, bufferLength)
        } 

        _batchHead.set(next);

        _batchDataStorage[next] = SSTORE2.write(
            buffer
        );
        __totalMinted += numToMint;
    }
}
