pragma solidity ^0.5.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./CDRW.sol";

contract Bank is Ownable {
    // PUBLIC VALUES
    mapping(address => bool) public registeredBankers;
    uint public registeredBankersCount = 0;

    uint public interestPoolBalance;
    mapping(address => uint) public bankerPoolBalance;
    mapping(address => mapping(uint => uint)) public bankerOpenCDs;

    mapping(address => uint) public rateIndex;
    uint[] public oneMonthRates;
    uint[] public threeMonthRates;
    uint[] public sixMonthRates;

    address internal dai;
    CDRW cdrw;

    event BankerInterestAddedToPool(
        address indexed bankerAddress,
        uint amount
    );

    event BankerInterestRemovedFromPool(
        address indexed bankerAddress,
        uint amount
    );

    event BankerRegistered(
        address indexed bankerAddress
    );

    event UpdatedBankerInterestRates(
        address indexed bankerAddress,
        uint oneMonthRate,
        uint threeMonthRate,
        uint sixMonthRate
    );

    event OpenedCertificateOfDeposit(
        address indexed bankerAddress,
        uint termLength,
        uint principleAmount,
        uint interestRate
    );

    event RedeemedCertificateOfDeposit(
        uint tokenId
    );

    constructor(address _cdTokenAddress, address _dai) public {
        cdrw = CDRW(_cdTokenAddress);
        dai = _dai;
    }

    modifier onlyRegistered() {
        require(registeredBankers[msg.sender], "Must be a registered Banker");
        _;
    }

    modifier notAlreadyRegistered() {
        require(registeredBankers[msg.sender] == false, "Already registered");
        _;
    }

    function registerBanker(uint oneMonth, uint threeMonths, uint sixMonths) notAlreadyRegistered public {
        registeredBankers[msg.sender] = true;
        registeredBankersCount++;

        rateIndex[msg.sender] = registeredBankersCount - 1;

        oneMonthRates.push(oneMonth);
        threeMonthRates.push(threeMonths);
        sixMonthRates.push(sixMonths);

        emit BankerRegistered(msg.sender);
    }

    function addBankerInterestToPool(uint amount) public onlyRegistered {
        bankerPoolBalance[msg.sender] = bankerPoolBalance[msg.sender] + amount;
        interestPoolBalance = interestPoolBalance + amount;

        ERC20(dai).transferFrom(msg.sender, address(this), amount);

        emit BankerInterestAddedToPool(msg.sender, amount);
    }

    function addBuyerDepositToPool(uint amount, address banker, uint termLength, uint principleAmount, uint interestAmount) public {
        interestPoolBalance = interestPoolBalance + amount;

        ERC20(dai).transferFrom(msg.sender, address(this), amount);

        openCertificateOfDeposit(
            msg.sender,
            banker,
            termLength,
            principleAmount,
            interestAmount
        );
    }

    function removeBankerInterestFromPool(uint amount) public onlyRegistered {
        require(amount <= bankerPoolBalance[msg.sender], "Not enough balance");

        bankerPoolBalance[msg.sender] = bankerPoolBalance[msg.sender] - amount;
        interestPoolBalance = interestPoolBalance - amount;

        ERC20(dai).transfer(msg.sender, amount);

        emit BankerInterestRemovedFromPool(msg.sender, amount);
    }

    function updateBankerInterestRates(uint oneMonth, uint threeMonths, uint sixMonths) onlyRegistered public {
        uint userIndexPosition = getUserIndexPosition();

        oneMonthRates[userIndexPosition] = oneMonth;
        threeMonthRates[userIndexPosition] = threeMonths;
        sixMonthRates[userIndexPosition] = sixMonths;

        emit UpdatedBankerInterestRates(msg.sender, oneMonth, threeMonths, sixMonths);
    }

    function getBestRate(uint termLength) public view returns (uint rate) {
        uint bestRate = 0;

        if(termLength == 1) {
            for(uint i = 0; i < oneMonthRates.length; i++) {
                if(oneMonthRates[i] > bestRate) {
                    bestRate = oneMonthRates[i];
                }
            }

            return(bestRate);
        } else if (termLength == 3) {
            for(uint i = 0; i < threeMonthRates.length; i++) {
                if(threeMonthRates[i] > bestRate) {
                    bestRate = threeMonthRates[i];
                }
            }

            return(bestRate);
        } else if (termLength == 6) {
            for(uint i = 0; i < sixMonthRates.length; i++) {
                if(sixMonthRates[i] > bestRate) {
                    bestRate = sixMonthRates[i];
                }
            }

            return(bestRate);
        }
    }

    function openCertificateOfDeposit(
        address _to,
        address _banker,
        uint _termLength,
        uint _principleAmount,
        uint _interestAmount
    ) internal {
        cdrw.createCertificateOfDeposit(
            _to,
            _banker,
            _termLength,
            _principleAmount,
            _interestAmount
        );

        emit OpenedCertificateOfDeposit(_banker, _termLength, _principleAmount, _interestAmount);
    }

    function redeemCertificateOfDeposit(
        uint tokenId
    ) public {
        cdrw.burn(tokenId);

        emit RedeemedCertificateOfDeposit(tokenId);
    }

    function getUserIndexPosition() public view returns(uint indexPosition) {
        return(rateIndex[msg.sender]);
    }
}