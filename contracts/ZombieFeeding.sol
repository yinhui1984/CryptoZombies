// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;

//about import:
// https://remix-ide.readthedocs.io/en/latest/import.html
import "./ZombieFactory.sol";

//about interface
//  https://solidity-by-example.org/interface/
abstract contract KittyInterface {
    function getKitty(uint256 _id)
        external
        view
        virtual
        returns (
            bool isGestating,
            bool isReady,
            uint256 cooldownIndex,
            uint256 nextActionAt,
            uint256 siringWithId,
            uint256 birthTime,
            uint256 matronId,
            uint256 sireId,
            uint256 generation,
            uint256 genes
        );
}

//aoubt inheritance:
// https://www.geeksforgeeks.org/solidity-inheritance/
contract ZombieFeeding is ZombieFactory {
    // 一个外部合约
    //https://bloxy.info/zh/address/0x06012c8cf97BEaD5deAe237070F9587f8E7A266d
    //0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    KittyInterface kittyContract;

    // https://docs.soliditylang.org/en/v0.8.16/contracts.html#function-modifiers
    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    // storage : 相当于指针
    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(block.timestamp + cooldownTime);
    }

    function _isReady(Zombie storage _zombie) internal view returns (bool) {
        bool ready = (_zombie.readyTime <= block.timestamp);
        console.log("[LOG] is ready to feed?", ready);
        return ready;
    }

    modifier onlyOwnerOf(uint256 _zombieId) {
        require(
            msg.sender == zombieToOwner[_zombieId],
            "message.sender should own the zombie"
        );
        _;
    }

    function feedAndMultiply(
        uint256 _zombieId,
        uint256 _targetDna,
        string memory _species
    ) internal onlyOwnerOf(_zombieId) {
        //about data location:
        //  https://medium.com/coinmonks/solidity-storage-vs-memory-vs-calldata-8c7e8c38bce
        //  https://solidity-by-example.org/data-locations/
        Zombie storage myZombie = zombies[_zombieId];

        require(_isReady(myZombie), "this zombie is not ready to feed");

        //确保参数不大于16位
        _targetDna = _targetDna % dnaModulus;
        uint256 newDna = (myZombie.dna + _targetDna) / 2;
        // solidity 不能直接比较字符串，要使用它们的hash值进行比较
        if (keccak256(abi.encodePacked(_species)) == keccak256("kitty")) {
            // 如果这个僵尸是一只猫变来的，就将它DNA的最后两位数字设置为99。
            newDna = newDna - (newDna % 100) + 99;
        }
        _createZombie("NoName", newDna);

        _triggerCooldown(myZombie);
    }

    function feedOnKitty(uint256 _zombieId, uint256 _kittyId) public {
        uint256 kittyDna;

        // !! kitty是部署在主网上的， 如果在本地网， 这里的getKitty是获取不了数据的：
        // ransact to ZombieFeeding.feedOnKitty errored: VM error: revert.

        // 只需要getKitty的10个返回值中的最后一个
        // (, , , , , , , , , kittyDna) = kittyContract.getKitty(_kittyId);

        // 这里使用一个随机数代替

        kittyDna = uint(
            keccak256(
                abi.encodePacked(
                    block.timestamp + _kittyId,
                    block.difficulty,
                    msg.sender
                )
            )
        );

        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}
