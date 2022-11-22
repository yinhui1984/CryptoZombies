const { expect } = require('chai');
const { ethers } = require('hardhat'); // https://docs.ethers.io/v5/
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe('ZombieFeeding Test Suits', function () {

    // https://hardhat.org/tutorial/testing-contracts#reusing-common-test-setups-with-fixtures
    // loadFixture将在第一次运行设置，并在其他测试中快速返回到该状态。
    async function deployContractFixture() {
        const [owner, addr1] = await ethers.getSigners();
        const facotry = await ethers.getContractFactory("ZombieFeeding");
        const contract = await facotry.deploy();
        return { contract, owner, addr1 };
    }


    it("测试Ownable", async function () {
        const { contract, owner, addr1 } = await loadFixture(deployContractFixture);

        console.log("owner address:", owner.address);
        console.log("another address:", addr1.address);

        await contract.setKittyContractAddress("0x06012c8cf97BEaD5deAe237070F9587f8E7A266d");
        //使用另外不是owner的一个账户， EVM会revert
        try {
            // about connect:
            //  https://hardhat.org/tutorial/testing-contracts#using-a-different-account
            await contract.connect(addr1).setKittyContractAddress("0x06012c8cf97BEaD5deAe237070F9587f8E7A266d");
        } catch (e) {
            console.log(e.message);
        }
    });

    it("测试冷却时间", async function () {
        const { contract, owner, addr1 } = await loadFixture(deployContractFixture);
        await contract.createRandomZombie("test");

        // 立即喂食，会失败
        let e = null;
        try {
            await contract.feedOnKitty(0, 1);
        } catch (error) {
            console.log(error.message);
            e = error;
        }

        expect(e, "evm should throw error").not.to.be.null;

        let zombiesCount = await contract.getOwnedZombiesCount();
        expect(zombiesCount).to.equal(1);

        // 等待冷却时间 
        // https://ethereum.stackexchange.com/questions/86633/time-dependent-tests-with-hardhat
        // https://github.com/trufflesuite/ganache/blob/ef1858d5d6f27e4baeb75cccd57fb3dc77a45ae8/src/chains/ethereum/ethereum/RPC-METHODS.md#evm_increasetime
        // 特殊调试方法
        // https://hardhat.org/hardhat-network/docs/reference#special-testing/debugging-methods
        await ethers.provider.send("evm_increaseTime", [60 * 60 * 24 + 1]);
        await ethers.provider.send("evm_mine");

        //投食成功
        await contract.feedOnKitty(0, 1);
        zombiesCount = await contract.getOwnedZombiesCount();
        expect(zombiesCount).to.equal(2);
    });
});