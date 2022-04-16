//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ArtX is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    event Mint(uint256 indexed id, address indexed owner);
    event List(uint256 indexed makerId, uint256 indexed takerId);
    event Deal(uint256 indexed makerId, uint256 indexed takerId);
    event Close(uint256 indexed makerId);

    // the swap pool
    // a token can be "made" only once, but can be proposed many times
    mapping (uint256 => uint256) private _pool;

    constructor() ERC721("ArtX", "ATX") {}

    // mint an ArtX token
    // an ArtX token is minted by the artist herself when she first uploaded the artwork
    // tokenURI points to the token's metadata
    function mint(string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        emit Mint(newItemId, msg.sender);

        return newItemId;
    }

    // Propose a swap. The maker (proposer) must be the owner of the maker token.
    // Past orders will be overwritten if called multiple times.
    function makeSwap(uint256 makerTokenId, uint256 takerTokenId) public {
        require(ownerOf(makerTokenId) == msg.sender);

        _pool[makerTokenId] = takerTokenId;  // ovewrite if not 0

        emit List(makerTokenId, takerTokenId);
    }

    // Accept the swap. The caller must own the taker token
    function takeSwap(uint256 makerTokenId, uint256 takerTokenId) public {
        require(_pool[makerTokenId] == takerTokenId);
        require(ownerOf(takerTokenId) == msg.sender);
        address maker = ownerOf(makerTokenId);
        address taker = msg.sender;

        _transfer(maker, taker, makerTokenId);  // tranfer to taker
        _transfer(taker, maker, takerTokenId);  // transfer to maker

        _pool[makerTokenId] = 0;
        
        emit Deal(makerTokenId, takerTokenId);
    }

    // Close the swap. A swap can be closed by either the maker (cancel) or the taker (reject)
    function closeSwap(uint256 makerTokenId) public {
        require(ownerOf(makerTokenId) == msg.sender || ownerOf(_pool[makerTokenId]) == msg.sender);

        _pool[makerTokenId] = 0;
        
        emit Close(makerTokenId);
    }

    function isInSwap(uint256 tokenId) public view returns (bool) {
        return _pool[tokenId] != 0;
    }
}
