// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@celo/protocol/contracts/common/Initializable.sol";
import "@celo/protocol/contracts/common/ReentrancyGuard.sol";
import "@celo/protocol/contracts/common/UsingRegistry.sol";
import "@celo/protocol/contracts/interfaces/IStableToken.sol";

contract DecentralizedExchange is Initializable, ReentrancyGuard, UsingRegistry {
    IStableToken public stableToken;
    mapping(address => uint256) public balances;

    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);
    event Trade(address indexed buyer, address indexed seller, uint256 amount);

    function initialize(address _stableToken) external initializer {
        stableToken = IStableToken(_stableToken);
    }

    function deposit(uint256 _amount) external {
        require(_amount > 0, "Invalid amount");

        stableToken.transferFrom(msg.sender, address(this), _amount);
        balances[msg.sender] += _amount;

        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external {
        require(_amount > 0, "Invalid amount");
        require(_amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= _amount;
        stableToken.transfer(msg.sender, _amount);

        emit Withdraw(msg.sender, _amount);
    }

    function trade(address _seller, uint256 _amount) external nonReentrant {
        require(_amount > 0, "Invalid amount");
        require(balances[_seller] >= _amount, "Insufficient seller balance");

        balances[_seller] -= _amount;
        balances[msg.sender] += _amount;

        emit Trade(msg.sender, _seller, _amount);
    }
}
