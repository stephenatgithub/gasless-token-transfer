// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Gas is ERC20, ERC20Permit {
    constructor() ERC20("Gas", "GAS") ERC20Permit("Gas") {
        _mint(msg.sender, 5000 );
    }
}

contract GaslessTokenTransfer {
    function send(
        address token,
        address sender,
        address receiver,
        uint256 amount,
        uint256 fee,
        uint256 deadline,
        // Permit signature
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // Permit
        Gas(token).permit(
            sender,
            address(this),
            amount + fee,
            deadline,
            v,
            r,
            s
        );

        // Send amount to receiver
        Gas(token).transferFrom(sender, receiver, amount);

        // Take fee - send fee to msg.sender
        Gas(token).transferFrom(sender, msg.sender, fee);
    }
}
