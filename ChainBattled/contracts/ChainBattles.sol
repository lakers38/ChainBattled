// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    struct Character {
        uint256 Level;
        string Speed;
        string Strength;
        string Life;
    }
    Character character;
    mapping(uint256 => Character) public characters;

    constructor() ERC721("Chain Battles", "CBTLS") {}

    function generateCharacter() public returns (string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Levels: ",
            character.Level.toString(),
            "</text>",
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Speed: ",
            character.Speed,
            "</text>",
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Strength: ",
            character.Strength,
            "</text>",
            '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Life: ",
            character.Life,
            "</text>",
            "</svg>"
        );

        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getTokenURI(uint256 tokenId) public returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function random(uint256 number) public view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        msg.sender
                    )
                )
            ) % number;
    }

    function mint() public {
        _tokenIds.increment();
        character = Character(
            random(100),
            random(100).toString(),
            random(100).toString(),
            random(100).toString()
        );

        uint256 newItemId = _tokenIds.current();
        characters[newItemId] = character;
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId));
        require(
            ownerOf(tokenId) == msg.sender,
            "You must own this NFT to train it!"
        );
        uint256 currentLevel = characters[tokenId].Level;
        characters[tokenId].Level = currentLevel + 1;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}
