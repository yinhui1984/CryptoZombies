
import { ethers } from "./ethers-5.1.esm.min.js";
import { cryptoZombiesABI, crytoZombiesContractAddres } from "./cryptozombies_abi.js"

let provider;
let signer, signerAddress;
let buttonConnect, buttonCreateZombie;
let labelZombieName, labelZombieDNA, labelZombieLevel, labelZombieWins, labelZombieLosses, labelZombieReadyTime;
let contract;

// // If you don't specify a //url//, Ethers connects to the default 
// // (i.e. ``http:/\/localhost:8545``)
// const provider = new ethers.providers.JsonRpcProvider();

// // The provider also allows signing transactions to
// // send ether and pay to change state within the blockchain.
// // For this, we need the account signer...
// const signer = provider.getSigner();

// // The Contract object
// const abi = JSON.parse(fs.readFileSync('./artifacts/contracts/ZombieOwnership.sol/ZombieOwnership.json')).abi;
// const address = "0x7E38AeE773c18BbC320A62f52300aa1dbB32C583";
// const contract = new ethers.Contract(address, abi, provider);


const initUI = () => {
    buttonConnect = document.getElementById('buttonConnect');
    buttonCreateZombie = document.getElementById('buttonCreateZombie');
    buttonCreateZombie.onclick = onCreateZombie;

    labelZombieName = document.getElementById('labelZombieName');
    labelZombieDNA = document.getElementById('labelZombieDNA');
    labelZombieLevel = document.getElementById('labelZombieLevel');
    labelZombieWins = document.getElementById('labelZombieWins');
    labelZombieLosses = document.getElementById('labelZombieLosses');
    labelZombieReadyTime = document.getElementById('labelZombieReadyTime');
}

const onClickConnect = async () => {
    try {
        // Will open the MetaMask UI
        provider = new ethers.providers.Web3Provider(window.ethereum, "any");
        provider.send("eth_requestAccounts", []);
        signer = provider.getSigner();
        signerAddress = await signer.getAddress();
        buttonConnect.innerText = signerAddress;
        buttonConnect.disabled = true;

        // the contract
        // 后面要使用这个contract进行函数调用， 那么这里的第三个参数必须传signer， 而不是provider
        contract = new ethers.Contract(crytoZombiesContractAddres, cryptoZombiesABI, signer);

    } catch (error) {
        console.error(error)
    }
}

const onCreateZombie = async () => {
    if (contract == null) {
        alert("Please connect to MetaMask first");
    }
    try {
        let zombiesList = await contract.getZombiesByOwner(signerAddress);
        if (zombiesList.length == 0) {
            let tx = await contract.createRandomZombie(signerAddress);
            await tx.wait();
            alert("Zombie created!");

        }
        let index = zombiesList[0];
        //访问属性 Zombie[] public zombies;
        let zombie = await contract.zombies(index)
        labelZombieName.innerText = "Name: " + zombie.name;
        labelZombieDNA.innerText = "DNA: " + zombie.dna;
        labelZombieLevel.innerText = "Level: " + zombie.level;
        labelZombieWins.innerText = "Wins: " + zombie.winCount;
        labelZombieLosses.innerText = "Losses: " + zombie.lossCount;
        //unix timestamp to date-time string
        let readyTime = new Date(zombie.readyTime * 1000).toLocaleString();
        labelZombieReadyTime.innerText = "ReadTime: " + readyTime
        console.log(zombie);
    } catch (e) {
        console.log(e);
    }


    //await contract.createRandomZombie(signerAddress);
}

const isMetaMaskInstalled = () => {
    //Have to check the ethereum binding on the window object to see if it's installed
    const { ethereum } = window;
    return Boolean(ethereum && ethereum.isMetaMask);
}

const MetaMaskClientCheck = () => {
    if (!isMetaMaskInstalled()) {
        buttonConnect.innerText = 'Please install MetaMask';
        //connectButton.onclick = onClickInstall;
        buttonConnect.disabled = true;
    } else {
        buttonConnect.innerText = 'Connect to MetaMask';
        buttonConnect.onclick = onClickConnect
    }
}




const startApp = async function () {
    console.log("start app...")
    initUI();
    MetaMaskClientCheck();

}

window.addEventListener("DOMContentLoaded", startApp);