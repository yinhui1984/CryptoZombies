// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

// 注释格式：  https://docs.soliditylang.org/en/v0.8.16/natspec-format.html

// https://consensys.net/blog/developers/solidity-best-practices-for-smart-contract-security/

// about import remapping
//  https://docs.soliditylang.org/en/latest/path-resolution.html#import-remapping
//  https://forum.openzeppelin.com/t/is-it-possible-to-import-openzeppelin-contract-from-github-to-vscode/10931
//  如果使用solc 编译：
//      1, clone github.com/OpenZeppelin/openzeppelin-contracts 到当前目录
//      2, solc带上参数 "github.com/OpenZeppelin/openzeppelin-contracts"="openzeppelin-contracts" --base-path .

//  if use remix: 可以直接使用github.com
//  import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";

// if use hardhat compile, please: npm install @openzeppelin/contracts
import "@openzeppelin/contracts/access/Ownable.sol";

// console : https://github.com/NomicFoundation/hardhat/blob/main/packages/hardhat-core/console.sol
import "hardhat/console.sol";

//import "@openzeppelin/contracts/access/Ownable.sol";

contract ZombieFactory is Ownable {
    //about accessibility
    //  https://oliverjumpertz.com/solidity-visibility-modifiers/

    uint256 dnaDigits = 16;
    uint256 dnaModulus = 10**dnaDigits; //a**n means a^n
    uint256 cooldownTime = 1 days; // 冷却时间

    /*
    通常情况下我们不会考虑使用 uint 变种，因为无论如何定义 uint的大小，Solidity 为它保留256位的存储空间。
    例如，使用 uint8 而不是uint（uint256）不会为你节省任何 gas。
    除非，把 uint 绑定到 struct 里面。
    如果一个 struct 中有多个 uint，则尽可能使用较小的 uint, Solidity 会将这些 uint 打包在一起，从而占用较少的存储空间
    所以，当 uint 定义在一个 struct 中的时候，尽量使用最小的整数子类型以节约空间。 
    并且把同样类型的变量放一起（即在 struct 中将把变量按照类型依次放置
    */
    struct Zombie {
        string name;
        uint256 dna;
        uint32 level;
        uint32 readyTime;
        uint16 winCount;
        uint16 lossCount;
    }

    Zombie[] public zombies;

    ///evnet when a new zombie is created
    event EventNewZombie(uint256 zombieId, string name, uint256 dna);

    ///僵尸（by id） 和 拥有者（by address） 之间的映射
    mapping(uint256 => address) public zombieToOwner;
    ///保存拥有者（by address）拥有的僵尸数
    mapping(address => uint256) ownerZombieCount;

    //Data location must be "memory" or "calldata" for parameter in function
    //private function should start with _

    /// create a zombie
    function _createZombie(string memory _name, uint256 _dna) internal {
        //push doesn't return length anymore
        //https://ethereum.stackexchange.com/questions/40312/what-is-the-return-of-array-push-in-solidity
        zombies.push(
            Zombie(_name, _dna, 1, uint32(block.timestamp + cooldownTime), 0, 0)
        );
        uint256 id = zombies.length - 1;

        //msg.sender 表示合约调用者的地址
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;

        // console.log("[LOG] zombie created");
        // console.log("\tid:", id);
        // console.log("\tname:", _name);
        // console.log("\tdna:", _dna);
        // console.log("\towner:", msg.sender);

        emit EventNewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string memory _str)
        private
        view
        returns (uint256)
    {
        //keccak256
        //  https://solidity-by-example.org/hashing/
        //  https://medium.com/0xcode/hashing-functions-in-solidity-using-keccak256-70779ea55bb0
        //abi.encodePacked:
        //  https://ethereum.stackexchange.com/questions/119583/when-to-use-abi-encode-abi-encodepacked-or-abi-encodewithsignature-in-solidity
        //  https://forum.openzeppelin.com/t/abi-encode-vs-abi-encodepacked/2948
        //  https://coinsbench.com/solidity-tutorial-all-about-abi-46da8b517e7
        //  https://docs.soliditylang.org/en/v0.8.11/abi-spec.html#non-standard-packed-mode
        uint256 rand = uint256(keccak256(abi.encodePacked(_str)));

        //我们只想让我们的DNA的长度为16位
        return rand % dnaModulus;
    }

    function createRandomZombie(string memory _name) public {
        // https://ethereum.stackexchange.com/questions/15166/difference-between-require-and-assert-and-the-difference-between-revert-and-thro
        require(
            0 == ownerZombieCount[msg.sender],
            "Only one zombie object can be created for one address"
        );

        uint256 randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }

    function getOwnedZombiesCount() public view returns (uint256) {
        return ownerZombieCount[msg.sender];
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    /**
     * @notice  将合约中的余额提款到owner
     * @dev     实际到账数量可能少于提款量， 要扣除旷工费
     */
    function withdraw() external onlyOwner {
        // 从solidity0.5以后下面这个有语法错误
        //https://docs.soliditylang.org/en/v0.5.0/050-breaking-changes.html#explicitness-requirements
        // The address type was split into address and address payable,
        // where only address payable provides the transfer function
        //owner().transfer(address(this).balance);
        payable(address(owner())).transfer(address(this).balance);
    }
}
