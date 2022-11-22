// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;

import "./ZombieFeeding.sol";

contract ZombieHelper is ZombieFeeding {
    // 1 ether = 10^18 wei
    // https://converter.murkin.me
    uint256 levelUpFee = 0.001 ether;
    // about modifier
    // https://www.geeksforgeeks.org/solidity-function-modifiers/
    modifier aboveLevel(uint256 _level, uint256 _zombieId) {
        require(
            zombies[_zombieId].level >= _level,
            "zombie level too low to change name"
        );
        _;
    }

    // payable:
    //  https://solidity-by-example.org/payable/
    //  payable 函数赚钱的ether会存放在合约地址中
    function levelUp(uint256 _zombieId) external payable {
        require(msg.value == levelUpFee, "some ethers needed to level up");
        zombies[_zombieId].level++;
    }

    function setLevelUpFee(uint256 _fee) external onlyOwner {
        levelUpFee = _fee;
    }

    function getLevelUpFee() external view returns (uint256) {
        return levelUpFee;
    }

    function changeName(uint256 _zombieId, string memory _newName)
        external
        aboveLevel(2, _zombieId) // 2级以上才可以改名称
        onlyOwnerOf(_zombieId)
    {
        zombies[_zombieId].name = _newName;
    }

    function changeDna(uint256 _zombieId, uint256 _newDna)
        external
        aboveLevel(20, _zombieId)
        onlyOwnerOf(_zombieId)
    {
        require(
            zombieToOwner[_zombieId] == msg.sender,
            "you are not the owner of this zombie"
        );
        zombies[_zombieId].dna = _newDna;
    }

    /**
     * @notice  获取指定地址所拥有的僵尸列表
     * @param   _owner  .
     * @return  uint256[]  返回的列表中的值是在zombies中的索引号
     */
    function getZombiesByOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        //about array:
        //  https://solidity-by-example.org/array/
        uint256[] memory result = new uint256[](ownerZombieCount[_owner]);
        uint256 counter = 0;
        for (uint i = 0; i < zombies.length; i++) {
            if (zombieToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }

        return result;
    }
}
