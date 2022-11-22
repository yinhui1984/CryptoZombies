
# https://stackoverflow.com/questions/3931741/why-does-make-think-the-target-is-up-to-date
.PHONY:  test tests

all:test


# init hardhat
init:
	npm init -y
	npm install --save-dev hardhat
	@echo  "\033[31m请选择创建空配置\033[m"
	-rm -f ./hardhat.config.js
	npx hardhat
	npm install --save-dev @nomicfoundation/hardhat-toolbox
	@#追加 @nomicfoundation/hardhat-toolbox 到 hardhat.config.js 顶部
	ex -sc '1i|require("@nomicfoundation/hardhat-toolbox");' -cx hardhat.config.js
	npm install @openzeppelin/contracts

compile:
	@#if use solc:
	@#solc github.com=.deps/github --include-path .deps/npm --abi --bin --base-path ./ --overwrite --pretty-json -o build/contracts/ contracts/ZombieFeeding.sol 
	@#if use hardhat:
	npx hardhat compile

deploy:
	@echo  "\033[31m部署合约\033[m" 
	@# 部署到哪里去了? 如果是localhost,那么就是本地占用8545端口的,比如ganache 或 hardhat node
	@# check 8548 port
	@if [ -z "$$(lsof -i:8545)" ]; then \
		echo "\033[31m !! no process is listening on port 8545, please run ganache or hardhat node first...\033[m"; \
		exit 1; \
	fi
	npx hardhat run scripts/deploy.js --network localhost



# https://www.npmjs.com/package/@remix-project/remixd
connectRemix:
	remixd -s ./ -u https://remix.ethereum.org

test:
	@echo  "\033[31m运行使用js编写的测试用例\033[m" 
	@# 后面跟文件路径可以只运行某个测试文件， 比如 npx hardhat test ./test/ZombieAttack.test.js 
	npx hardhat test

# https://remix-ide.readthedocs.io/en/latest/unittestingAsCLI.html#command-line-interface
# remix-tests 会自动编译修改的合约
test2:
	@echo  "\033[31m运行使用solidity编写的测试用例\033[m"
	remix-tests --compiler 0.8.4 ./tests


app:
	@echo  "\033[31m运行前端应用\033[m"
	serve