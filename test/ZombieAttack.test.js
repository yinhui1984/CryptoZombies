const { expect } = require('chai');
const { ethers } = require('hardhat'); // https://docs.ethers.io/v5/
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe('ZombieAttack Test Suits', function () {

    // https://hardhat.org/tutorial/testing-contracts#reusing-common-test-setups-with-fixtures
    // loadFixture将在第一次运行设置，并在其他测试中快速返回到该状态。
    async function deployContractFixture() {
        const [owner, addr1] = await ethers.getSigners();
        const facotry = await ethers.getContractFactory("ZombieAttack");
        const contract = await facotry.deploy();
        return { contract, owner, addr1 };
    }

    it("测试attack", async function () {
        const { contract, owner, addr1 } = await loadFixture(deployContractFixture);

        await contract.createRandomZombie("me");
        await contract.connect(addr1).createRandomZombie("enemy");
        // 非常重要， 下面这个是得不到winerId的， 返回的是tx
        // https://ethereum.stackexchange.com/questions/111916/hardhat-test-returns-transaction-instead-of-return-value
        // https://stackoverflow.com/questions/72356857/how-to-receive-a-value-returned-by-a-solidity-smart-contract-transacting-functio
        // 从一个事务中返回的值在EVM之外是不可用的。你可以发出一个event，或者创建一个public view的取值函数。
        // let winerId = await contract.attack(0, 1);
        // console.log("winerId:", winerId);

        await contract.attack(0, 1);

    });

});