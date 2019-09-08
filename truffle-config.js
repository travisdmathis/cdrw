/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * truffleframework.com/docs/advanced/configuration
 *
 * To deploy via Infura you'll need a wallet provider (like truffle-hdwallet-provider)
 * to sign your transactions before they're sent to a remote public node. Infura accounts
 * are available for free at: infura.io/register.
 *
 * You'll also need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. If you're publishing your code to GitHub make sure you load this
 * phrase from a file you've .gitignored so it doesn't accidentally become public.
 *
 */

// const HDWalletProvider = require('truffle-hdwallet-provider');
// const infuraKey = "fj4jll3k.....";
//
// const fs = require('fs');
// const mnemonic = fs.readFileSync(".secret").toString().trim();
const HDWalletProvider = require("@truffle/hdwallet-provider");

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 9545,
      network_id: "*" // Match any network id
    },
    goerli: {
      provider: function() {
        return new HDWalletProvider("kit aisle equal convince shoulder sea exile treat code thrive hawk exercise", "https://goerli.infura.io/v3/cc5ed2a2b6a54ac98242535069613019")
      },
      network_id: 5,
      gas: 4000000      //make sure this gas allocation isn't over 4M, which is the max
    },
    kovan: {
      provider: function() {
        return new HDWalletProvider("kit aisle equal convince shoulder sea exile treat code thrive hawk exercise", "https://kovan.infura.io/v3/cc5ed2a2b6a54ac98242535069613019")
      },
      network_id: 42,
      gas: 4000000      //make sure this gas allocation isn't over 4M, which is the max
    },
    rinkeby: {
      provider: function() {
        return new HDWalletProvider("kit aisle equal convince shoulder sea exile treat code thrive hawk exercise", "https://rinkeby.infura.io/v3/cc5ed2a2b6a54ac98242535069613019")
      },
      network_id: 4,
      gas: 4000000      //make sure this gas allocation isn't over 4M, which is the max
    }
  },
  plugins: [
    'truffle-plugin-verify'
  ],
  api_keys: {
    etherscan: '68TAGW44FCDBQIQH49PQCJYPFSSN1Q873T'
  },
  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      // version: "0.5.1",    // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      // settings: {          // See the solidity docs for advice about optimization and evmVersion
      //  optimizer: {
      //    enabled: false,
      //    runs: 200
      //  },
      //  evmVersion: "byzantium"
      // }
    }
  }
}
