const CDRW = artifacts.require("./CDRW.sol");
const Bank = artifacts.require("./Bank.sol");
const BankOracle = artifacts.require("./BankOracle.sol");

module.exports = async function(deployer) {
  deployer.deploy(CDRW, "Certificate of Deposit", "CD").then(async (cdToken) => {
    await CDRW.deployed();
    await deployer.deploy(Bank, CDRW.address, '0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa');
    await Bank.deployed();

    cdToken.transferOwnership(Bank.address);

    await deployer.deploy(BankOracle);
    BankOracle.deployed();
  });
};