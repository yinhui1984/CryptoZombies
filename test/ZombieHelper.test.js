const { expect } = require('chai');
const { ethers } = require('hardhat'); // https://docs.ethers.io/v5/
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { add } = require('lodash');

describe('ZombieHelper Test Suits', function () {

    // https://hardhat.org/tutorial/testing-contracts#reusing-common-test-setups-with-fixtures
    // loadFixture将在第一次运行设置，并在其他测试中快速返回到该状态。
    async function deployContractFixture() {
        const [owner, addr1] = await ethers.getSigners();
        const facotry = await ethers.getContractFactory("ZombieHelper");
        const contract = await facotry.deploy();
        return { contract, owner, addr1 };
    }

    it("测试changeName", async function () {
        const { contract, owner, addr1 } = await loadFixture(deployContractFixture);

        await contract.createRandomZombie("test");

        //刚刚生成的zombie时修改名字会失败
        let e = null;
        try {
            await contract.changeName(0, "newName");
        } catch (error) {
            console.log(error.message);
            e = error;
        }
        expect(e).not.to.be.null;

        // 升级后修改名称
        await contract.levelUp(0, { value: ethers.utils.parseEther("0.001") });
        await contract.changeName(0, "newName");

        //升级后用其他地址修改名称会失败
        e = null;
        try {
            await contract.connect(addr1).changeName(0, "newName2");
        } catch (error) {
            console.log(error.message);
            e = error;
        }
        expect(e).not.to.be.null;

    });

    it("测试getZombiesByOwner", async function () {
        const { contract, owner, addr1 } = await loadFixture(deployContractFixture);
        contract.createRandomZombie("test");
        let zombiesList = await contract.getZombiesByOwner(owner.address);
        expect(zombiesList.length).to.equal(1);

        zombiesList = await contract.getZombiesByOwner(addr1.address);
        expect(zombiesList.length).to.equal(0);
    });

    it("测试levelUp", async function () {
        const { contract, owner, addr1 } = await loadFixture(deployContractFixture);
        contract.createRandomZombie("test");

        //用另外一个地址来进行支付升级费用
        let balanceBefore = await addr1.getBalance();
        let a = await contract.getBalance();
        await contract.connect(addr1).levelUp(0, { from: addr1.address, value: ethers.utils.parseEther("0.001") });
        let balanceAfter = await addr1.getBalance();
        let b = await contract.getBalance();
        console.log("caller balance before %s, after %s, fee %s ether", balanceBefore.toString(), balanceAfter.toString(), balanceBefore.sub(balanceAfter) / (10 ** 18));
        console.log("contract balance before %s, after %s, gained %s ether", a.toString(), b.toString(), b.sub(a) / (10 ** 18));
        expect(balanceAfter).to.lt(balanceBefore);
        expect(b).to.gt(a);
    });

    it("测试withdraw", async function () {
        const { contract, owner, addr1 } = await loadFixture(deployContractFixture);
        contract.createRandomZombie("test");
        await contract.levelUp(0, { value: ethers.utils.parseEther("0.001") });


        let balanceBefore = await owner.getBalance();
        let a = await contract.getBalance();
        await contract.withdraw();
        let b = await contract.getBalance();
        let balanceAfter = await owner.getBalance();
        console.log("contract balance before %s, after %s, withdraw %s ether", a.toString(), b.toString(), a.sub(b) / (10 ** 18));
        console.log("owner balance before %s, after %s, gained %s ether", balanceBefore.toString(), balanceAfter.toString(), balanceAfter.sub(balanceBefore) / (10 ** 18));

        expect(b).to.lt(a);
        expect(balanceAfter).to.gt(balanceBefore);

        //非owner提款会失败
        let e = null;
        try {
            await contract.connect(addr1).withdraw();
        } catch (error) {
            console.log(error.message);
            e = error;
        }

        expect(e).is.not.null;

    });

    it("测试setLevelUpFee", async function () {
        const { contract, owner, addr1 } = await loadFixture(deployContractFixture);
        contract.createRandomZombie("test");
        await contract.levelUp(0, { value: ethers.utils.parseEther("0.001") });

        //非owner设置会失败
        let e = null;
        try {
            await contract.connect(addr1).setLevelUpFee(ethers.utils.parseEther("0.002"));
        } catch (error) {
            console.log(error.message);
            e = error;
        }
        expect(e).is.not.null;

        //设置升级费用
        await contract.setLevelUpFee(ethers.utils.parseEther("0.002"));
        let fee = await contract.getLevelUpFee();
        expect(fee).to.equal(ethers.utils.parseEther("0.002"));

        //升级费用不够会失败
        e = null;
        try {
            await contract.levelUp(0, { value: ethers.utils.parseEther("0.001") });
        } catch (error) {
            console.log(error.message);
            e = error;
        }
        expect(e).is.not.null;

        //升级费用够了
        await contract.levelUp(0, { value: ethers.utils.parseEther("0.002") });
    });
});