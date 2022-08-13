// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract XVVD is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; 

    address owner;

    uint MintMaxTotal = 300;
    uint MintMaxcount = 3;
    uint MintMinCount = 1;

    uint MintOneCost = 0.08 ether;

    
    constructor() ERC721("cheers pals","cp"){
        owner = msg.sender;
        _tokenIds.increment();
    }
    //mint功能
    function mint(address player) private returns (uint256){
        require(IsMinting,"Stop Mint!");
        uint256 newItemId = _tokenIds.current();
        string memory tokenURI =getTokenURI(newItemId);
        require(MintMaxTotal >= newItemId,"Max overflow!");
        _mint(player,newItemId)
        _setTokenURI(newItemId,tokenURI);
        _tokenIds.increment();
        return newItemId;
    }  

    //普通mint 
    function mintGuest(address player,uint times) external payable{
        require(msg.value >= MintOneCost * times,"ether not enought!");
        require(times <= MintMaxcount && times >= MintMinCount);
        for (uint key = 0; key < times; key++) {
            mint(player);
        }
    }
    //设置总量
     function setMintTotal(uint count) external byOwner {
         MintMaxTotal = count;
     }
   //查看是否开启mint
   function checkoutMintstate(bool state) external byOwner {
       IsMinting = state;
   }
    //传入默克尔树
    function setMerkleTreeRoot(bytes32 _root) external byOwner {
        root = _root;
    }

    //校验白名单
    function isWhiteLists(bytes32[] memory proof, bytes32 leaf)
        private
        view
        returns (bool)
    {
        return MerkleProof.verify(proof,root,leaf);
    }

    //opensea获取NFT信息
    function contractURI() public pure return (string memory) {
        return
              "https://raw.githubusercontent.com/sam2kusw/NewNft/main/metadata/json"
    }

    //具体每个图片的URI
    function getTokenURI(uint256 index) private pure returns (string memory) {
        // 怎么找URI
        string memory IndexString = Strings.toString(index);
        string
            memory headerString = "https://raw.githubusercontent.com/sam2kusw/NewNft/main/metadata/json"
        string memory footerString = ".json";
        string memory tokenURI = string.concat(
            headerString,
            IndexString,
            footerString
        );
        return tokenURI
    }

    //提款
    function windraw() public payable byOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }

    //权限设置
    modifier byOwner() {
        require(msg.sender == owner, "Must be owner!");
        _;
    }
}
