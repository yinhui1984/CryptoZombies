// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;

import "./ZombieAttack.sol";

// 更好的方式：使用 openzeppelin的ERC721.sol
//https://www.npmjs.com/package/@openzeppelin/contracts
//https://docs.openzeppelin.com/contracts/3.x/erc721
//https://docs.openzeppelin.com/contracts/3.x/api/token/erc721
//import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./erc721.sol";

// https://docs.openzeppelin.com/contracts/4.x/api/utils#SafeMath
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

//ERC721:
//  https://ethereum.org/zh/developers/docs/standards/tokens/erc-721/
//  https://learnblockchain.cn/2018/03/23/token-erc721

contract ZombieOwnership is ZombieAttack, ERC721 {
    using SafeMath for uint256;

    mapping(uint256 => address) zombieApprovals;

    function balanceOf(address _owner)
        public
        view
        virtual
        override
        returns (uint256 _balance)
    {
        return ownerZombieCount[_owner];
    }

    function ownerOf(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (address _owner)
    {
        return zombieToOwner[_tokenId];
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) private {
        ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
        ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);
        zombieToOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function transfer(address _to, uint256 _tokenId)
        public
        virtual
        override
        onlyOwnerOf(_tokenId)
    {
        _transfer(msg.sender, _to, _tokenId);
    }

    function approve(address _to, uint256 _tokenId)
        public
        virtual
        override
        onlyOwnerOf(_tokenId)
    {
        zombieApprovals[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }

    function takeOwnership(uint256 _tokenId) public virtual override {
        require(zombieApprovals[_tokenId] == msg.sender);
        _transfer(ownerOf(_tokenId), msg.sender, _tokenId);
    }
}
