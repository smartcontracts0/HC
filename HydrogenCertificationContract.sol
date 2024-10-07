// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RegistrationContract.sol";
import "./EnergyCertificationContract.sol";

contract HydrogenCertificationContract {
    RegistrationContract public registrationContract;
    EnergyCertificationContract public energyCertificationContract;

    // Mapping to link hydrogen suppliers to their customers
    mapping(address => address) public hydrogenSupplierToCustomer;

    // Event to log the linking of a hydrogen supplier to a customer
    event HydrogenSupplierLinkedToCustomer(address indexed hydrogenSupplier, address indexed customer);

    event HydrogenCertified(address indexed supplier, uint256 hydrogenProducedInKg, uint256 totalCO2, uint256 timestamp);

    constructor(RegistrationContract _registrationContract, EnergyCertificationContract _energyCertificationContract) {
        registrationContract = _registrationContract;
        energyCertificationContract = _energyCertificationContract;
    }

    modifier onlyAuthorizedHydrogenSupplier() {
        require(
            registrationContract.isStakeholderRegistered(msg.sender, RegistrationContract.StakeholderType.HydrogenSupplier),
            "Caller is not a registered Hydrogen Supplier"
        );
        require(
            registrationContract.getAuthorizationStatus(msg.sender),  
            "Hydrogen Supplier is not authorized"
        );
        _;
    }

     function certifyHydrogen(
        uint256 powerUsedInkWh,
        uint256 hydrogenProducedInKg,
        uint256 conversionRatio,
        uint256 hydrogenCO2PerKg,
        address customer
    ) external onlyAuthorizedHydrogenSupplier {
        // Link the customer
        require(customer != address(0), "Invalid customer address");
        require(registrationContract.isStakeholderRegistered(customer, RegistrationContract.StakeholderType.Customer),
            "Customer is not registered");

        hydrogenSupplierToCustomer[msg.sender] = customer;
        emit HydrogenSupplierLinkedToCustomer(msg.sender, customer);

        // Ensure the conversion ratio is correct
        require(powerUsedInkWh > 0 && hydrogenProducedInKg > 0, "Invalid input values");
        require(conversionRatio > 0, "Conversion ratio must be greater than zero");
        require(powerUsedInkWh * conversionRatio == hydrogenProducedInKg, "Conversion ratio does not match the provided values");

        // Retrieve the linked energy supplier
        address energySupplier = energyCertificationContract.getEnergyToHydrogenLink(msg.sender);

        require(energySupplier != address(0), "Energy supplier not linked");

        // Check certified energy
        uint256 certifiedEnergy = energyCertificationContract.certifiedEnergyForHydrogenSupplier(msg.sender);
        require(certifiedEnergy >= powerUsedInkWh, "Insufficient certified energy for this amount of hydrogen production");


        uint256 energyCO2 = energyCertificationContract.getCO2PerKWhForSupplier(energySupplier) * powerUsedInkWh;
        uint256 totalCO2 = energyCO2 + (hydrogenCO2PerKg * hydrogenProducedInKg);

        // Subtract the used energy from the certified energy
        energyCertificationContract.decreaseCertifiedEnergy(msg.sender, powerUsedInkWh);

        // Emit an event to log the hydrogen certification
        emit HydrogenCertified(msg.sender, hydrogenProducedInKg, totalCO2, block.timestamp);
    }
}