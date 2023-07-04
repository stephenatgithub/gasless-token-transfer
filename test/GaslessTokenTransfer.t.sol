// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/GaslessTokenTransfer.sol";

contract GaslessTokenTransferTest is Test {
    GaslessTokenTransfer private gaslessTokenTransfer;
    Gas private gas;

    address sender;
    address receiver;
    address agent;

    uint256 sender_privateKey = 123;
    uint constant amount = 1000;
    uint constant fee = 10;

    function setUp() public {        
        sender = vm.addr(sender_privateKey);
        receiver = address(2);
        agent = address(999);

        vm.prank(sender);
        gas = new Gas();
        //console.log("Gas deployed to ", address(gas));
        //console.log("sender balance ", gas.balanceOf(sender));

        gaslessTokenTransfer = new GaslessTokenTransfer();        
        //console.log("GaslessTokenTransfer deployed to ", address(gaslessTokenTransfer));
        
        //vm.deal(address(gaslessTokenTransfer), 100 ether);
        //console.log("gaslessTokenTransfer balance ", address(gaslessTokenTransfer).balance);
    }

    function testValidSig() public {
        console.log("=================BEFORE====================== ");
        console.log("sender balance ", address(sender).balance, gas.balanceOf(sender));        
        console.log("receiver balance ", address(receiver).balance, gas.balanceOf(receiver));
        console.log("agent balance ", address(agent).balance, gas.balanceOf(agent));
        console.log("gaslessTokenTransfer balance ", address(gaslessTokenTransfer).balance, gas.balanceOf(address(gaslessTokenTransfer)));
    
        uint256 deadline = block.timestamp + 60;

        // Sender - prepare permit signature
        bytes32 permitHash = _getPermitHash(
            sender,
            address(gaslessTokenTransfer),
            amount + fee,
            gas.nonces(sender),
            deadline
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(sender_privateKey, permitHash);

        // Execute transfer
        vm.startPrank(agent);
        gaslessTokenTransfer.send(
            address(gas), sender, receiver, amount, fee, deadline, v, r, s
        );

        console.log("=================AFTER====================== ");
        console.log("sender balance ", address(sender).balance, gas.balanceOf(sender));        
        console.log("receiver balance ", address(receiver).balance, gas.balanceOf(receiver));
        console.log("agent balance ", address(agent).balance, gas.balanceOf(agent));
        console.log("gaslessTokenTransfer balance ", address(gaslessTokenTransfer).balance, gas.balanceOf(address(gaslessTokenTransfer)));
    }

    function _getPermitHash(
        address owner,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline
    ) private view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                "\x19\x01",
                gas.DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        keccak256(
                            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                        ),
                        owner,
                        spender,
                        value,
                        nonce,
                        deadline
                    )
                )
            )
        );
    }
}
