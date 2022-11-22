// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.4.22 <0.9.0;

import "remix_tests.sol";
import "remix_accounts.sol";
import "../contracts/ZombieFactory.sol";

contract testZombieFactory {
    ZombieFactory contractFactory;

    function beforeEach() public {
        contractFactory = new ZombieFactory();
    }

    /*
    function checkSuccess() public {
        // Use 'Assert' to test the contract, 
        // See documentation: https://remix-ide.readthedocs.io/en/latest/assert_library.html
        Assert.equal(uint(2), uint(2), "2 should be equal to 2");
        Assert.notEqual(uint(2), uint(3), "2 should not be equal to 3");
    }

    function testABC() public view returns (bool) {
        return 1==1;
    }

    */

    function testCreateRandomZombie() public {
        string memory name = "zhou";
        contractFactory.createRandomZombie(name);

        Assert.ok(
            contractFactory.getOwnedZombiesCount() != 0,
            "should create one zombie, and msg.sender owns it"
        );
    }
}
