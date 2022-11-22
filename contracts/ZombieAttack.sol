// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;

import "./ZombieHelper.sol";

contract ZombieAttack is ZombieHelper {
    uint256 randNonce = 0;
    uint256 attackVictoryProbability = 70;

    /**
     * @notice  随机数生成函数
     * @dev     不安全的， https://ethereum.stackexchange.com/questions/191/how-can-i-securely-generate-a-random-number-in-my-smart-contract
     * @param   _max  .
     * @return  uint256  .
     */
    function randMod(uint256 _max) internal returns (uint256) {
        randNonce++;
        uint256 rand = uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))
        ) % _max;
        console.log("[LOG] created random number:", rand);
        return rand;
    }

    function attack(uint256 _zombieId, uint256 _targetId)
        external
        onlyOwnerOf(_zombieId)
        returns (uint256)
    {
        Zombie storage myZombie = zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];

        uint rand = randMod(100);

        if (rand <= attackVictoryProbability) {
            myZombie.winCount++;
            myZombie.level++;
            enemyZombie.lossCount++;
            if (_isReady(myZombie)) {
                feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
            }
            return _zombieId;
        } else {
            myZombie.lossCount++;
            enemyZombie.winCount++;
            _triggerCooldown(myZombie);
            return _targetId;
        }
    }
}
