// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CryptoStakeNFT is ERC721Enumerable, Ownable {
    // token base URI
    string private _baseTokenURI;

    // Mapping URI and token Id
    mapping(uint256 => string) private URI;

    // Mapping address to admin
    mapping(address => bool) private admin;

    /**
     * @dev Emitted when `address` is added or removed to be admin
     */
    event AddAdmin(address indexed adminAddress, bool indexed isAdmin);

    /**
     * @dev Required `address` admin or owner can access
     */
    modifier onlyAdminOrOwner() {
        require(
            admin[_msgSender()] || _msgSender() == owner(),
            "CrytoStakeNFT: Only the admin or owner can be access"
        );
        _;
    }

    /**
     * @dev Sets the values for {name}, {symbol} and {baseURI}.
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(
        string memory name,
        string memory symbol,
        string memory baseURI
    ) ERC721(name, symbol) {
        setBaseURI(baseURI);
    }

    /**
     * @dev Returns the base of the token.
     */
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev Returns the base of the token.
     */
    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }


    /**
     * @dev Returns the TokenURI of the token.
     * Requirements:
     *
     * `tokenId` must exist
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        string memory baseURI = _baseURI();
        string memory token = URI[tokenId];

        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, "/", token))
                : "";
    }

    /**
     * @dev mint new `tokenID` to address `to`
     * then setting for the "uri"
     * Requirements:
     *
     * `id` must not exist
     * `to` must not address(0)
     * `uri` must be valid
     *
     * Emits a {Transfer} event.
     */
    function mint(
        address to,
        uint256 id,
        string memory uri
    ) external {
        require(bytes(uri).length > 0, "CrytoStakeNFT: NFT URI must be valid");
        _safeMint(to, id);
        URI[id] = uri;
    }

    /**
     * @dev mint batch new `tokenIDs` to array address `to`
     * then setting for the "uri"
     * Requirements:
     *
     * `ids` must not exist
     * `to` must be valid address
     * `uri` must be valid
     * length of array ids, to, uri must be the same
     *
     * Emits {Transfer} event.
     */
    function mintBatch(
        address[] calldata to,
        uint256[] calldata ids,
        string[] calldata uri
    ) external onlyAdminOrOwner {
        require(
            to.length > 0,
            "CrytoStakeNFT: Length of params must greater than 0"
        );
        require(
            to.length <= 100,
            "CrytoStakeNFT: Only can mint 100 NFT a time"
        );
        require(
            to.length == ids.length && ids.length == uri.length,
            "CrytoStakeNFT: Amount of input must be the same"
        );
        uint256 length = ids.length;
        for (uint256 i = 0; i < length; i++) {
            _safeMint(to[i], ids[i]);
            URI[ids[i]] = uri[i];
        }
    }

    /**
     * @dev add or remove `address` in mapping `admin`
     * only Owner or Admin can access to this function
     * Requirements:
     *
     * `adminAddress` must be valid address
     * `isAdmin` true for adding new admin
     * `isAdmin` false for removing admin
     *
     * Emits a {AddAdmin} event.
     */
    function addOrRemoveAdmin(address adminAddress, bool isAdmin)
        external
        onlyAdminOrOwner
    {
        admin[adminAddress] = isAdmin;
        emit AddAdmin(adminAddress, isAdmin);
    }

    /**
     * @dev show all TokenId  of  the `holder`.
     *
     *
     */
    function tokensOfOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokensId;
    }
}
