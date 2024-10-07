# Hydrogen Certification Smart Contracts

This repository contains the Solidity smart contracts designed for a blockchain-based hydrogen certification system. These contracts enable stakeholders (such as hydrogen and energy suppliers, certification authorities, auditors, and customers) to register, authorize, and certify the production and sustainability of hydrogen using a decentralized, transparent, and immutable system.

## Contracts Overview

1. RegistrationContract.sol
Handles the registration of all stakeholders (energy suppliers, hydrogen suppliers, auditors, and customers) and their respective smart meters. This contract is the foundation of the system, ensuring that only verified and authorized participants can take part in the certification process.

2. EnergyCertificationContract.sol
Manages the certification of energy used in hydrogen production. This contract records the energy inputs and outputs from energy suppliers, calculates carbon emissions, and ensures that only energy meeting sustainability criteria is linked to hydrogen production.

3. HydrogenCertificationContract.sol
Facilitates the certification of hydrogen production. It verifies the energy-to-hydrogen conversion ratio, calculates the total CO2 emissions for hydrogen production, and certifies the hydrogen output based on the sustainability of the energy inputs.

## Getting Started
### Prerequisites
To deploy and interact with these smart contracts, you will need the following:

* REMIX IDE (or any Solidity-compatible IDE)
* Solidity Compiler (version 0.8.0 or higher)
* Access to an Ethereum testnet (such as Ropsten or Rinkeby) or a local Ethereum node (such as Ganache)

### Installation and Deployment
1. Clone this repository:

```bash
git clone https://github.com/your-repository/hydrogen-certification.git
cd hydrogen-certification
```

2. Open REMIX IDE (https://remix.ethereum.org) and upload the three smart contracts from this repository:

* RegistrationContract.sol
* EnergyCertificationContract.sol
* HydrogenCertificationContract.sol
  
Compile each contract in REMIX by selecting the Solidity Compiler and ensuring the correct version (0.8.0 or higher).

Deploy the contracts in the following order:

1. Deploy the RegistrationContract.sol to initialize the registration of stakeholders and smart meters.
   
2. Deploy the EnergyCertificationContract.sol to manage energy certification.
   
3. Deploy the HydrogenCertificationContract.sol to handle the hydrogen certification process.
   
Ensure that the deployed contract addresses are correctly linked when interacting with the respective contracts.

## Usage
1. Registering Stakeholders:
Use the RegistrationContract to register energy suppliers, hydrogen producers, auditors, and customers. Only certification authorities are permitted to register new participants. Each participant must have their smart meter calibrated and registered through this contract.

2. Certifying Energy:
Once registered, energy suppliers can certify the energy they provide to hydrogen producers using the EnergyCertificationContract. The contract records the energy amounts, calculates associated carbon emissions, and generates energy certificates.

3. Certifying Hydrogen:
Hydrogen producers can then use the HydrogenCertificationContract to certify their hydrogen production. This contract verifies the energy-to-hydrogen conversion ratio and certifies hydrogen outputs based on the sustainability of the energy inputs.

## Testing
To test the contracts:

1. Use a local blockchain environment such as Ganache for deployment, or deploy to a testnet (e.g., Ropsten).
   
2. Ensure each stakeholder registers their smart meters through the RegistrationContract before proceeding with certification.
   
3. Use REMIX’s testing environment to simulate transactions between stakeholders.
   
## Contributing
Feel free to open issues or submit pull requests if you find bugs or want to add new features.
