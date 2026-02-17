// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

error Donate__InvalidAddress();
error Donate__DonationMustBeGreaterThanZero();
error Donate__DonateFailed();
error Donate__MaxMessageLimitReached();
error Withdraw__ZeroBalance();
error Withdraw__WithdrawFailed();
error Receive__DirectTransferNotAllowed();

contract CryptoDonation is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    struct DonationHistory {
        address from;
        address to;
        uint256 value;
    }

    uint8 public constant COMMISSION_RATE = 5;
    uint8 public constant MAX_MESSAGE_LENGTH = 255;

    DonationHistory[] private allDonations;
    mapping(address => DonationHistory[]) private donationsBySender;
    mapping(address => DonationHistory[]) private donationsByReceiver;

    uint256[50] private __gap;

    event Donate(address indexed from, address indexed to, uint256 indexed amount, string message);
    event Withdraw(address indexed from, address indexed to, uint256 indexed amount);

    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Ownable_init(msg.sender);
    }

    function _authorizeUpgrade(address newImplementation) internal view override onlyOwner {}

    function withdraw(address to) external onlyOwner {
        if (address(this).balance == 0) revert Withdraw__ZeroBalance();

        uint256 lastContractBalance = address(this).balance;

        (bool success,) = payable(to).call{value: address(this).balance}("");

        if (!success) revert Withdraw__WithdrawFailed();

        emit Withdraw(address(this), to, lastContractBalance);
    }

    function donate(address to, string calldata message) public payable {
        if (to == address(0)) revert Donate__InvalidAddress();
        if (msg.value == 0) revert Donate__DonationMustBeGreaterThanZero();
        if (bytes(message).length > MAX_MESSAGE_LENGTH) revert Donate__MaxMessageLimitReached();

        allDonations.push(DonationHistory(msg.sender, to, msg.value));
        donationsBySender[msg.sender].push(DonationHistory(msg.sender, to, msg.value));
        donationsByReceiver[to].push(DonationHistory(msg.sender, to, msg.value));

        uint256 amountAfterCommission = msg.value - (msg.value * COMMISSION_RATE / 100);

        (bool success,) = payable(to).call{value: amountAfterCommission}("");

        if (!success) revert Donate__DonateFailed();

        emit Donate(msg.sender, to, msg.value, message);
    }

    function getAllDonations() external view returns (DonationHistory[] memory) {
        return allDonations;
    }

    function getDonationsBySender(address sender) external view returns (DonationHistory[] memory) {
        return donationsBySender[sender];
    }

    function getDonationsByReceiver(address receiver) external view returns (DonationHistory[] memory) {
        return donationsByReceiver[receiver];
    }

    receive() external payable {
        revert Receive__DirectTransferNotAllowed();
    }
}
