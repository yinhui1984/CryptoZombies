const { expect, assert } = require('chai');
const { ethers } = require('hardhat'); // https://docs.ethers.io/v5/
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe('ZombieFactory Test Suits', function () {

    // https://hardhat.org/tutorial/testing-contracts#reusing-common-test-setups-with-fixtures
    // loadFixture将在第一次运行设置，并在其他测试中快速返回到该状态。
    async function deployContractFixture() {
        const [owner, addr1] = await ethers.getSigners();
        const facotry = await ethers.getContractFactory("ZombieFactory");
        const contract = await facotry.deploy();
        return { contract, owner, addr1 };
    }

    it("测试createRandomZombie", async function () {
        const { contract, owner, addr1 } = await loadFixture(deployContractFixture);
        let countBefore = await contract.getOwnedZombiesCount();
        await contract.createRandomZombie("test");
        let countAfter = await contract.getOwnedZombiesCount();

        //about .to .be .with ..
        // https://www.chaijs.com/api/bdd/
        expect(countAfter).to.equal(countBefore + 1);

    });

    it("测试同一地址重复调用createRandomZombie", async function () {

        const { contract, owner, addr1 } = await loadFixture(deployContractFixture);
        let countBefore = await contract.getOwnedZombiesCount();
        await contract.createRandomZombie("test");

        // 第二次调用应该被evm revert
        let e = null;
        try {
            await contract.createRandomZombie("test2");
        } catch (error) {
            console.log(error.message);
            e = error;
        }
        // https://www.chaijs.com/api/bdd/#method_null
        //expect(e).not.to.be.null;
        expect(e, "evm should throw error").not.to.be.null;

        let countAfter = await contract.getOwnedZombiesCount();
        expect(countAfter).to.equal(countBefore + 1);
    });
});
