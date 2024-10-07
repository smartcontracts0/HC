//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RegistrationContract.sol";


contract EnergyCertificationContract {
    RegistrationContract public registrationContract;

    address public hydrogenCertificationContract; // Address of the HydrogenCertificationContract
    address public owner;

    mapping(address => uint256) public certifiedEnergyForHydrogenSupplier;
    mapping(address => address) public energyToHydrogenLink;
    mapping(address => uint256) public co2PerKWh; // CO2 emissions per kWh of certified energy

        constructor(RegistrationContract _registrationContract) {
        registrationContract = _registrationContract;
        owner = msg.sender;  // Set the deployer as the owner
    }
    
    // Modifier that checks if the caller is an authorized power supplier with the required meters
    modifier onlyAuthorizedPowerSupplier() {
        require(
            registrationContract.isStakeholderRegistered(msg.sender, RegistrationContract.StakeholderType.PowerSupplier),
            "Caller is not a registered Power Supplier"
        );

        require(
            registrationContract.getAuthorizationStatus(msg.sender),  // Using explicit getter
            "Power Supplier is not authorized"
        );
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function certifyEnergyForHydrogenSupplier(uint256 amount, uint256 CO2perKWH, address hydrogenSupplier) external onlyAuthorizedPowerSupplier {
        require(registrationContract.isStakeholderRegistered(hydrogenSupplier, RegistrationContract.StakeholderType.HydrogenSupplier), "Not a registered Hydrogen Supplier");
        require(registrationContract.getAuthorizationStatus(hydrogenSupplier), "Hydrogen Supplier is not authorized");
        require(amount > 0, "Amount must be greater than zero");

        energyToHydrogenLink[msg.sender] = hydrogenSupplier;
        certifiedEnergyForHydrogenSupplier[hydrogenSupplier] += amount;
        co2PerKWh[hydrogenSupplier] = CO2perKWH;

        // Establish link from this energy supplier to the hydrogen supplier
        energyToHydrogenLink[hydrogenSupplier] = msg.sender;

        emit EnergyCertifiedForHydrogenSupplier(msg.sender, hydrogenSupplier, amount, CO2perKWH);
    }
    // Function to decrease the certified energy for a hydrogen supplier
    // Function to be called by the HydrogenCertificationContract to decrease certified energy
    function decreaseCertifiedEnergy(address hydrogenSupplier, uint256 energyUsedInkWh) public {
        require(msg.sender == hydrogenCertificationContract, "Unauthorized caller");
    // Ensure there is enough certified energy before decreasing
        require(certifiedEnergyForHydrogenSupplier[hydrogenSupplier] >= energyUsedInkWh, "Insufficient Certified Energy");
    // Decrease the certified energy
        certifiedEnergyForHydrogenSupplier[hydrogenSupplier] -= energyUsedInkWh;
    }

    // Function to get CO2 per kWh for a specific energy supplier
        function getCO2PerKWhForSupplier(address energySupplier) external view returns (uint256) {
        return co2PerKWh[energySupplier];
    }

        function getEnergyToHydrogenLink(address hydrogenSupplier) public view returns (address) {
        return energyToHydrogenLink[hydrogenSupplier];
    }

    // Setter function to be called once to set the address of the HydrogenCertificationContract
    function setHydrogenCertificationContract(address _hydrogenCertificationContract) public onlyOwner {
        hydrogenCertificationContract = _hydrogenCertificationContract;
    }

    event EnergyCertifiedForHydrogenSupplier(address indexed powerSupplier, address indexed hydrogenSupplier, uint256 amount, uint256 co2Amount);
}