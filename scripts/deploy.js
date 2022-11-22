const { ethers } = require("hardhat");

async function main() {
    const facotry = await ethers.getContractFactory("ZombieOwnership");
    const contract = await facotry.deploy();
    console.log("Contract deployed:");
    console.log("   address:", contract.address);
    console.log("   transaction:", contract.deployTransaction.hash);
    console.log("   singer address:", contract.signer.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});