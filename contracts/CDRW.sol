// CertificateOfDeposit.sol
// - mints a ERC721 to represent the CD
// - allows holders to redeem the CD at any time
pragma solidity ^0.5.0;

// IMPORTS
import "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

contract CDRW is ERC721Full, ERC721Burnable, Ownable  {
    // TOKEN METADATA ONCHAIN TO PREVENT FRAUD
    struct DepositMetaData {
        address banker;
        uint termLength;
        uint principleAmount;
        uint interestAmount;
        uint timestamp;
        uint tokenId;
    }

    mapping(uint256 => DepositMetaData) public depositMetaData;

    constructor(string memory _name,  string memory _symbol)
    ERC721Full(_name, _symbol) 
    public {}

    function createCertificateOfDeposit(
        address _to,
        address _banker,
        uint _termLength,
        uint _principleAmount,
        uint _interestAmount
    ) public onlyOwner returns(bool success) {
        uint256 _nextTokenId = _getNextTokenId();
        uint _timestamp = block.timestamp;

        depositMetaData[_nextTokenId] = DepositMetaData({
            banker: _banker,
            termLength: _termLength,
            principleAmount: _principleAmount,
            interestAmount: _interestAmount,
            timestamp: _timestamp,
            tokenId: _nextTokenId
        });

        _mint(_to, _nextTokenId);
        
        return(true);
    }

    function _getNextTokenId() private view returns (uint256) {
        return totalSupply().add(1);
    }
}
