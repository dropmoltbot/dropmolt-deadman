// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title DeadManSwitch
 * @author dropxtor (@0xDropxtor)
 * @notice Onchain dead man's switch for crypto wallets.
 *         If the owner doesn't check in within the timeout window,
 *         a designated beneficiary can claim all funds.
 *
 * Personal problem: If I disappear (death, abduction, lost keys, prison),
 * my crypto is lost forever. This contract ensures my beneficiaries get access.
 *
 * Built for the BuildAnything Spark Hackathon — powered by Monad.
 */

contract DeadManSwitch {
    /* ── Events ── */
    event CheckIn(address indexed owner, uint256 timestamp, uint256 newDeadline);
    event BeneficiaryUpdated(address indexed oldBeneficiary, address indexed newBeneficiary);
    event TimeoutUpdated(uint256 oldTimeout, uint256 newTimeout);
    event Claimed(address indexed beneficiary, uint256 amount, uint256 timestamp);
    event Funded(address indexed from, uint256 amount, uint256 balance);
    event Canceled(uint256 timestamp);

    /* ── State ── */
    address public owner;
    address public beneficiary;
    uint256 public lastCheckIn;
    uint256 public timeout; // seconds between required check-ins
    bool public canceled;
    bool public claimed;

    /* ── Modifiers ── */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "Not beneficiary");
        _;
    }

    modifier notCanceled() {
        require(!canceled, "Switch canceled");
        _;
    }

    modifier notClaimed() {
        require(!claimed, "Already claimed");
        _;
    }

    /* ── Constructor ── */
    constructor(address _beneficiary, uint256 _timeout) payable {
        require(_beneficiary != address(0), "Invalid beneficiary");
        require(_beneficiary != msg.sender, "Beneficiary cannot be owner");
        require(_timeout > 0, "Timeout must be > 0");

        owner = msg.sender;
        beneficiary = _beneficiary;
        timeout = _timeout;
        lastCheckIn = block.timestamp;

        if (msg.value > 0) {
            emit Funded(msg.sender, msg.value, address(this).balance);
        }
    }

    /* ── Owner functions ── */

    /// @notice Check in to reset the dead man's switch timer
    function checkIn() external onlyOwner notCanceled notClaimed {
        lastCheckIn = block.timestamp;
        emit CheckIn(msg.sender, block.timestamp, block.timestamp + timeout);
    }

    /// @notice Update the beneficiary
    function updateBeneficiary(address _newBeneficiary) external onlyOwner notCanceled notClaimed {
        require(_newBeneficiary != address(0), "Invalid beneficiary");
        require(_newBeneficiary != owner, "Beneficiary cannot be owner");

        address old = beneficiary;
        beneficiary = _newBeneficiary;

        emit BeneficiaryUpdated(old, _newBeneficiary);
    }

    /// @notice Update the timeout period
    function updateTimeout(uint256 _newTimeout) external onlyOwner notCanceled notClaimed {
        require(_newTimeout > 0, "Timeout must be > 0");

        uint256 old = timeout;
        timeout = _newTimeout;

        emit TimeoutUpdated(old, _newTimeout);
    }

    /// @notice Cancel the switch and withdraw all funds to owner
    function cancel() external onlyOwner notClaimed {
        require(!canceled, "Already canceled");

        canceled = true;

        uint256 balance = address(this).balance;
        if (balance > 0) {
            (bool sent, ) = payable(owner).call{value: balance}("");
            require(sent, "Failed to withdraw");
        }

        emit Canceled(block.timestamp);
    }

    /// @notice Withdraw partial funds while switch is active
    function withdraw(uint256 _amount) external onlyOwner notCanceled notClaimed {
        require(_amount > 0, "Amount must be > 0");
        require(_amount <= address(this).balance, "Insufficient balance");

        (bool sent, ) = payable(owner).call{value: _amount}("");
        require(sent, "Withdrawal failed");

        emit Funded(msg.sender, 0, address(this).balance);
    }

    /* ── Beneficiary functions ── */

    /// @notice Claim all funds if the owner has not checked in within the timeout
    function claim() external onlyBeneficiary notCanceled notClaimed {
        require(block.timestamp >= lastCheckIn + timeout, "Owner still active");

        claimed = true;

        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to claim");

        (bool sent, ) = payable(beneficiary).call{value: balance}("");
        require(sent, "Claim transfer failed");

        emit Claimed(msg.sender, balance, block.timestamp);
    }

    /* ── View functions ── */

    /// @notice Check if the owner is considered "dead" (missed check-in)
    function isDead() public view returns (bool) {
        return !canceled && !claimed && block.timestamp >= lastCheckIn + timeout;
    }

    /// @notice Get the deadline for the next required check-in
    function deadline() external view returns (uint256) {
        return lastCheckIn + timeout;
    }

    /// @notice Get seconds remaining until the beneficiary can claim
    function timeRemaining() external view returns (uint256) {
        if (canceled || claimed) return 0;

        uint256 _deadline = lastCheckIn + timeout;
        if (block.timestamp >= _deadline) return 0;

        return _deadline - block.timestamp;
    }

    /// @notice Fund the switch with ETH
    function fund() external payable onlyOwner notCanceled notClaimed {
        require(msg.value > 0, "Must send ETH");
        emit Funded(msg.sender, msg.value, address(this).balance);
    }

    /// @notice Get the current balance of the switch
    function balance() external view returns (uint256) {
        return address(this).balance;
    }

    /// @notice Get switch status summary
    function status() external view returns (
        address _owner,
        address _beneficiary,
        uint256 _balance,
        uint256 _lastCheckIn,
        uint256 _timeout,
        uint256 _timeRemaining,
        bool _isDead,
        bool _canceled,
        bool _claimed
    ) {
        _owner = owner;
        _beneficiary = beneficiary;
        _balance = address(this).balance;
        _lastCheckIn = lastCheckIn;
        _timeout = timeout;

        if (canceled || claimed) {
            _timeRemaining = 0;
        } else {
            uint256 _deadline = lastCheckIn + timeout;
            _timeRemaining = block.timestamp >= _deadline ? 0 : _deadline - block.timestamp;
        }

        _isDead = isDead();
        _canceled = canceled;
        _claimed = claimed;
    }

    /* ── Receive ── */
    receive() external payable {
        emit Funded(msg.sender, msg.value, address(this).balance);
    }
}
