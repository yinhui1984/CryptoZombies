# CryptoZombies
 CryptoZombies练习代码



## 安装依赖包

```npm i```



## 编译

`make compile`

```bash
❯ make compile                                 
npx hardhat compile
Compiled 10 Solidity files successfully
```

### 测试 (js)

`make test`

```bash
 ❯ make test                      
运行使用js编写的测试用例
npx hardhat test


  ZombieAttack Test Suits
[LOG] created random number: 23
[LOG] is ready to feed? false
    ✔ 测试attack (1278ms)

  ZombieFactory Test Suits
    ✔ 测试createRandomZombie (80ms)
VM Exception while processing transaction: reverted with reason string 'Only one zombie object can be created for one address'
    ✔ 测试同一地址重复调用createRandomZombie (66ms)

  ZombieFeeding Test Suits
owner address: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
another address: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
VM Exception while processing transaction: reverted with reason string 'Ownable: caller is not the owner'
    ✔ 测试Ownable (66ms)
[LOG] is ready to feed? false
VM Exception while processing transaction: reverted with reason string 'this zombie is not ready to feed'
[LOG] is ready to feed? true
    ✔ 测试冷却时间 (68ms)

  ZombieHelper Test Suits
VM Exception while processing transaction: reverted with reason string 'zombie level too low to change name'
VM Exception while processing transaction: reverted with reason string 'message.sender should own the zombie'
    ✔ 测试changeName (102ms)
    ✔ 测试getZombiesByOwner (38ms)
caller balance before 9999999748831100682322, after 9999998712984342380706, fee 0.001035846758301616 ether
contract balance before 0, after 1000000000000000, gained 0.001 ether
    ✔ 测试levelUp (41ms)
contract balance before 1000000000000000, after 0, withdraw 0.001 ether
owner balance before 9999986394917750550099, after 9999987360431273699675, gained 0.000965513523149576 ether
VM Exception while processing transaction: reverted with reason string 'Ownable: caller is not the owner'
    ✔ 测试withdraw (52ms)
VM Exception while processing transaction: reverted with reason string 'Ownable: caller is not the owner'
VM Exception while processing transaction: reverted with reason string 'some ethers needed to level up'
    ✔ 测试setLevelUpFee (64ms)

  ZombieOwnership Test Suits
    ✔ 测试transferFrom (151ms)


  11 passing (2s)
```



## 测试 (solidity)

`make test2`



```bash
❯ make test2                                  
运行使用solidity编写的测试用例
remix-tests --compiler 0.8.4 ./tests

	👁	:: Running tests using remix-tests ::	👁

[14:11:02] info: Compiler version set to 0.8.4. Latest version is 0.8.17
[14:11:02] info: 2 Solidity test files found
Loading remote solc version v0.8.4+commit.c7e474f2 ...
'creation of library remix_tests.sol:Assert pending...'

	◼  testZombieFactory


	✓  Test create random zombie

	◼  testZombieFedding




Tests Summary:
Passed: 1
Failed: 0
Time Taken: 0.257s
```







## 部署合约

1. 启动本地节点
   比如`hardhat node` 或运行 `Ganache`客户端 以监听8545端口

2. `make deploy`

   ```bash
   ❯ make deploy                               
   部署合约
   npx hardhat run scripts/deploy.js --network localhost
   Contract deployed:
      address: 0xdCc84d118C21838758cBFeC708a263aa4a58Dfbd
      transaction: 0x5f1bfda5133cb9bf2a17daadbfddfb5e0d1a50c43aaf125d5c25af1cb2f17742
      singer address: 0xe149d5f732685669C9E494B233fDB4312d19b5cF
   ```
   
3. 使用`artifacts/contracts/ZombieOwnership.sol/ZombieOwnership.json`中的abi和合约地址更新`cryptozombies_abi.js`

## 运行前端dapp

> 记得先部署合约!

`make app`

```bash
❯ make app                                     
运行前端应用
serve
WARNING: Checking for updates failed (use `--debug` to see full error)

   ┌─────────────────────────────────────────────────┐
   │                                                 │
   │   Serving!                                      │
   │                                                 │
   │   - Local:            http://localhost:3000     │
   │   - On Your Network:  http://172.20.10.2:3000   │
   │                                                 │
   │   Copied local address to clipboard!            │
   │                                                 │
   └─────────────────────────────────────────────────┘

```

<img src="https://github.com/yinhui1984/imagehosting/blob/main/images/1669098340190255000.jpg?raw=true" alt="image" style="zoom:50%;" />

​     

<img src="https://github.com/yinhui1984/imagehosting/blob/main/images/1669098378734344000.jpg?raw=true" alt="image" style="zoom:50%;" />

<img src="https://github.com/yinhui1984/imagehosting/blob/main/images/1669098419905594000.jpg?raw=true" alt="image" style="zoom:50%;" />



## 其他

`make connectRemix`:  启动 `remixd` 以便链接到浏览器的remix ide, 以调试solidity

`init:` 初始化项目
