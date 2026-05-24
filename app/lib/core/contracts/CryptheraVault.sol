// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CryptheraVault {
    address public owner;
    bool public isInactive;
    uint256 public totalAllocatedPercent;

    struct Beneficiary {
        address walletAddress;
        uint256 allocationPercent;
        bool hasClaimed;
    }

    Beneficiary[] public beneficiaries;

    event Deposited(address indexed sender, uint256 amount);
    event BeneficiaryAdded(address indexed wallet, uint256 allocation);
    event InactivityTriggered();
    event InactivityReset();
    event FundsClaimed(address indexed beneficiary, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    modifier whenInactive() {
        require(isInactive, "Vault is not flagged as inactive");
        _;
    }

    constructor() {
        owner = msg.sender;
        isInactive = false;
    }

    // Receive ETH deposits
    receive() external payable {
        emit Deposited(msg.sender, msg.value);
    }

    // Deposit function helper
    function deposit() external payable {
        emit Deposited(msg.sender, msg.value);
    }

    // Set or update beneficiaries
    function setBeneficiaries(
        address[] calldata _addresses,
        uint256[] calldata _allocations
    ) external onlyOwner {
        require(_addresses.length == _allocations.length, "Mismatched arrays length");
        
        // Reset existing beneficiaries array
        delete beneficiaries;
        totalAllocatedPercent = 0;

        for (uint256 i = 0; i < _addresses.length; i++) {
            require(_addresses[i] != address(0), "Invalid beneficiary address");
            require(_allocations[i] > 0 && _allocations[i] <= 100, "Invalid allocation percentage");
            
            beneficiaries.push(Beneficiary({
                walletAddress: _addresses[i],
                allocationPercent: _allocations[i],
                hasClaimed: false
            }));
            
            totalAllocatedPercent += _allocations[i];
            emit BeneficiaryAdded(_addresses[i], _allocations[i]);
        }

        require(totalAllocatedPercent <= 100, "Total allocations exceed 100%");
    }

    // Manual inactivity simulation trigger for hackathon demo
    function simulateInactivity() external onlyOwner {
        isInactive = true;
        emit InactivityTriggered();
    }

    // Owner check-in reset trigger
    function resetInactivity() external onlyOwner {
        isInactive = false;
        emit InactivityReset();
    }

    // Claim funds by a beneficiary
    function claimFunds() external whenInactive {
        int256 index = -1;
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            if (beneficiaries[i].walletAddress == msg.sender) {
                index = int256(i);
                break;
            }
        }

        require(index >= 0, "Caller is not a registered beneficiary");
        uint256 uIndex = uint256(index);
        
        require(!beneficiaries[uIndex].hasClaimed, "Allocation already claimed");
        
        uint256 balance = address(this).balance;
        require(balance > 0, "No vault balance available to claim");

        uint256 claimAmount = (balance * beneficiaries[uIndex].allocationPercent) / 100;
        require(claimAmount > 0, "Calculated claim amount is zero");

        beneficiaries[uIndex].hasClaimed = true;
        
        payable(msg.sender).transfer(claimAmount);
        emit FundsClaimed(msg.sender, claimAmount);
    }

    // Helper functions to inspect status
    function getVaultBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getBeneficiaryCount() external view returns (uint256) {
        return beneficiaries.length;
    }
}
