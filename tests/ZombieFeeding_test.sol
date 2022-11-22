// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol";

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/ZombieFeeding.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testZombieFedding {
    ZombieFeeding feedingContract;

    function beforeEach() public {
        feedingContract = new ZombieFeeding();
    }

    function testSetKittyContractAddress() public {
        //TODO
    }
}
