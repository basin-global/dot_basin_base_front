// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import "base64-sol/base64.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title .basin TLD Metadata contract v0.5 (based on FlexiPunkMetadata)
/// @author TMO
/// @notice Contract that stores metadata for TLD contracts.
contract dotBasinMetadataV0point5 {
  mapping (address => string) public descriptions; // TLD-specific descriptions, mapping(tldAddress => description)
  mapping (address => string) public brands; // TLD-specific brand names, mapping(tldAddress => brandName)

  // EVENTS
  event BrandChanged(address indexed user, string brand);
  event DescriptionChanged(address indexed user, string description);

  // READ
  function getMetadata(string calldata _domainName, string calldata _tld, uint256 _tokenId) public view returns(string memory) {
    string memory fullDomainName = string(abi.encodePacked(_domainName, _tld));

    return string(
      abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(abi.encodePacked(
        '{"name": "', fullDomainName, '", ',
        '"description": "', descriptions[msg.sender], '", ',
        '"image": "', _getImage(fullDomainName, brands[msg.sender]), '"}'))))
    );
  }

  function _getImage(string memory _fullDomainName, string memory _brandName) internal pure returns (string memory) {
    // IPFS URL for the image
    string memory ipfsImageURL = string(abi.encodePacked("https://ipfs.io/ipfs/QmdUfr2FyNhsWr5CBfFrXYPypMoFLEnQ5kzciBZrFogtxS"));

    string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 500" width="500" height="500">',
        '<image href="', ipfsImageURL, '" width="500" height="500"/>',
        '<text x="50%" y="50%" dominant-baseline="middle" fill="white" text-anchor="middle" font-family="monospace" font-size="24px" font-weight="bold">',
        _fullDomainName,'</text><text x="50%" y="70%" dominant-baseline="middle" fill="white" text-anchor="middle" font-family="monospace" font-size="20px">',
        _brandName,'</text>',
      '</svg>'
    ))));

    return string(abi.encodePacked("data:image/svg+xml;base64,", svgBase64Encoded));
  }

  function getTldOwner(address _tldAddress) public view returns(address) {
    Ownable tld = Ownable(_tldAddress);
    return tld.owner();
  }

  // WRITE (TLD OWNERS)

  /// @notice Only TLD contract owner can call this function.
  function changeBrand(address _tldAddress, string calldata _brand) external {
    require(msg.sender == getTldOwner(_tldAddress), "Sender not TLD owner");
    brands[_tldAddress] = _brand;
    emit BrandChanged(msg.sender, _brand);
  }

  /// @notice Only TLD contract owner can call this function.
  function changeDescription(address _tldAddress, string calldata _description) external {
    require(msg.sender == getTldOwner(_tldAddress), "Sender not TLD owner");
    descriptions[_tldAddress] = _description;
    emit DescriptionChanged(msg.sender, _description);
  }
}
