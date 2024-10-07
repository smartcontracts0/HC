// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RegistrationContract {
    enum StakeholderType { CertificationAuthority, PowerSupplier, HydrogenSupplier, Auditor, Customer }
    enum SmartMeterType { Energy, Carbon, Hydrogen } //define as needed

    struct Stakeholder {
        mapping(StakeholderType => bool) roles;
        bool isAuthorized;
        string documentHash; // IPFS hash
        // ... Additional properties as required
    }

    struct SmartMeter {
        SmartMeterType meterType;
        string parameters; // Serial number, calibration data, etc.
        bool isRegistered;
    }

        struct SupplierInfo {
        bool hasEnergyMeter;
        bool hasCarbonMeter;
        bool hasHydrogenMeter;
    }

    mapping(address => Stakeholder) public stakeholders;
    mapping(address => mapping(SmartMeterType => SmartMeter)) public smartMeters; 
    mapping(address => SupplierInfo) private supplierInfo;


    address public certificationAuthority;

    event StakeholderRegistered(address indexed stakeholder, StakeholderType stakeholderType);
    event StakeholderAuthorized(address indexed stakeholder);
    event SmartMeterRegistered(address indexed supplier, SmartMeterType meterType);
    event StakeholderRevoked(address indexed stakeholder, StakeholderType stakeholderType);

    constructor() {
        certificationAuthority = msg.sender;
        stakeholders[msg.sender].roles[StakeholderType.CertificationAuthority] = true;
        emit StakeholderRegistered(msg.sender, StakeholderType.CertificationAuthority);
    }

    modifier onlyCertificationAuthority() {
        require(msg.sender == certificationAuthority, "Not a certification authority");
        _;
    }
/*       modifier onlySupplier() {
        require(stakeholders[msg.sender].roles[StakeholderType.PowerSupplier] || stakeholders[msg.sender].roles[StakeholderType.HydrogenSupplier], "Not a supplier");
       _;
    }
*/  
// This modifier ensures that the energy supplier has registered both energy and carbon smart meters.
    modifier hasRequiredMetersForPowerSupplier(address supplier) {
        require(
            supplierInfo[supplier].hasEnergyMeter && supplierInfo[supplier].hasCarbonMeter,
            "Power Supplier must have both energy and carbon smart meters"
        );
        _;
    }


// This modifier ensures that the hydrogen supplier has registered both carbon and hydrogen smart meters.
    modifier hasRequiredMetersForHydrogenSupplier(address supplier) {
        require(
            supplierInfo[supplier].hasCarbonMeter && supplierInfo[supplier].hasHydrogenMeter,
            "Hydrogen Supplier must have both carbon and hydrogen smart meters"
        );
        _;
    }


    function registerStakeholder(address account, StakeholderType stakeholderType) public onlyCertificationAuthority {
        require(!stakeholders[account].roles[stakeholderType], "Already registered");
        stakeholders[account].roles[stakeholderType] = true;
        emit StakeholderRegistered(account, stakeholderType);
    }

    function registerSmartMeter(address supplier, SmartMeterType meterType, string memory parameters) public onlyCertificationAuthority {
        SmartMeter storage meter = smartMeters[supplier][meterType];
        require(!meter.isRegistered, "Smart meter type already registered for the supplier");

        meter.meterType = meterType;
        meter.parameters = parameters;
        meter.isRegistered = true;

        // Update the supplier info based on the meter type
        if (meterType == SmartMeterType.Energy) {
            supplierInfo[supplier].hasEnergyMeter = true;
        } else if (meterType == SmartMeterType.Carbon) {
            supplierInfo[supplier].hasCarbonMeter = true;
        } else if (meterType == SmartMeterType.Hydrogen) {
            supplierInfo[supplier].hasHydrogenMeter = true;
        }

        emit SmartMeterRegistered(supplier, meterType);
    }

    function authorizeSupplier(address supplier, StakeholderType stakeholderType) public onlyCertificationAuthority {
        if (stakeholderType == StakeholderType.PowerSupplier) {
            require(supplierInfo[supplier].hasEnergyMeter && supplierInfo[supplier].hasCarbonMeter,
            "Missing required smart meters for Power Supplier");
        } else if (stakeholderType == StakeholderType.HydrogenSupplier) {
            require(supplierInfo[supplier].hasCarbonMeter && supplierInfo[supplier].hasHydrogenMeter,
            "Missing required smart meters for Hydrogen Supplier");
        } else {
            revert("Invalid stakeholder type for authorization");
        }
        stakeholders[supplier].isAuthorized = true;
        emit StakeholderAuthorized(supplier);
    }

    function revokeStakeholder(address account) public onlyCertificationAuthority {
        // Assume all roles are revoked for simplicity
        for (uint i = 0; i < uint(StakeholderType.Customer); i++) {
            stakeholders[account].roles[StakeholderType(i)] = false;
        }
        stakeholders[account].isAuthorized = false;
        emit StakeholderRevoked(account, StakeholderType.PowerSupplier); 
    }

    function isStakeholderRegistered(address account, StakeholderType stakeholderType) public view returns (bool) {
        return stakeholders[account].roles[stakeholderType];
    }

    function updateDocumentHash(address stakeholder, string memory hash) public onlyCertificationAuthority {
        stakeholders[stakeholder].documentHash = hash;
        // an event can be added for document hash update
    }
        // Function to check if a supplier is authorized
    function isAuthorized(address stakeholder) public view returns (bool) {
        return stakeholders[stakeholder].isAuthorized;
    }

   // Add an explicit getter for the authorization status     
   function getAuthorizationStatus(address stakeholder) public view returns (bool) {
        return stakeholders[stakeholder].isAuthorized;
    }

}


