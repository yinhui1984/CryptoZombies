const { expect } = require('chai');
const { ethers } = require('hardhat'); // https://docs.ethers.io/v5/
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe('ZombieOwnership Test Suits', function () {
    // https://hardhat.org/tutorial/testing-contracts#reusing-common-test-setups-with-fixtures
    // loadFixture将在第一次运行设置，并在其他测试中快速返回到该状态。
    async function deployContractFixture() {
        const [owner, addr1] = await ethers.getSigners();
        const facotry = await ethers.getContractFactory("ZombieOwnership");
        const contract = await facotry.deploy();
        return { contract, owner, addr1 };
    }

    it("测试transferFrom", async function () {
        const { contract, owner, addr1 } = await loadFixture(deployContractFixture);

        await contract.createRandomZombie("Z1");
        await contract.connect(addr1).createRandomZombie("Z2");

        contract.balanceOf(owner.address).then((balance) => {
            expect(balance).to.equal(1);
        });

        contract.ownerOf(0).then((_owner) => {
            expect(_owner).to.equal(owner.address);
        });

        contract.balanceOf(addr1.address).then((balance) => {
            expect(balance).to.equal(1);
        });

        contract.ownerOf(1).then((_owner) => {
            expect(_owner).to.equal(addr1.address);
        });

        //------------测试transferFrom, 两者的zombie互换-----------------

        //将owner的Z1转移给addr1
        await contract.transfer(addr1.address, 0);
        contract.balanceOf(owner.address).then((balance) => {
            //转移后，token数量减少
            expect(balance).to.equal(0);
        });
        contract.balanceOf(addr1.address).then((balance) => {
            //转移后，token数量增加
            expect(balance).to.equal(2);
        });

        //addr1将Z2转移给owner, 用另外一种方式转移
        //拥有者先批准转移, 接收者再takeOwnership
        await contract.connect(addr1).approve(owner.address, 1);
        await contract.connect(owner).takeOwnership(1);
        contract.balanceOf(owner.address).then((balance) => {
            expect(balance).to.equal(1);
        });
        contract.balanceOf(addr1.address).then((balance) => {
            expect(balance).to.equal(1);
        });

        //---------------关于事件监听：---------------
        //https://docs.ethers.io/v5/api/contract/contract/#Contract--events
        //https://medium.com/txstreet/listening-to-events-in-hardhat-using-ethers-js-3e8c56b35aca
        let tx = await contract.connect(owner).transfer(addr1.address, 1);
        let receipt = await tx.wait();
        let event = receipt.events[0];
        expect(event.event).to.equal("Transfer");
        expect(event.args._from).to.equal(owner.address);
        expect(event.args._to).to.equal(addr1.address);
        expect(event.args._tokenId).to.equal(1);
    });
});
