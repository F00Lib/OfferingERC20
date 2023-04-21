//SPDX-License-Identifier:UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoERC20 is ERC20, Ownable{
    //price of one token 
    uint256 public constant tokenPrice = 0.001 ether;
    //each NFT would give the user 10 tokens
    uint256 public constant tokensPerNFT = 10*10**18;
    //max total supply
    uint256 public constant maxTotalSupply = 10000*10**18;
    
    ICryptoDevs CrypDevsNFT;
    //mapping to keep track of which tokenids have been claimed
    mapping(uint256=>bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsContract) ERC20("CryptoToken","CT"){
        CrypDevsNFT=ICryptoDevs(_cryptoDevsContract);
    }
    
    //Mint amount number of tokens 
    function mint(uint256 amount) public payable{
        uint256 _requiredAmount = tokenPrice*amount;
        require(msg.value>=_requiredAmount,"Overmint");
        uint256 amountWithDecimals = amount *10**18;
        require((totalSupply()+amountWithDecimals)<=maxTotalSupply,
            "Exceeds the max total supply available."
        );

        _mint(msg.sender,amountWithDecimals);
    }

    //mint tokens based on the number of NFT held by the sender
    //token shouldn't be claimed for all the NFT owned by the sender
    function claim() public {
        address sender = msg.sender;
        uint256 balance = CrypDevsNFT.balanceOf(sender);
        //if the balance is zero revert
        require(balance>0,"You dont have any Crypto NFT");
        //amount keeps track of number of unclaimed tokenIds
        uint256 amount = 0;
        //loop and get the token ID owned by sender at a given index
        for(uint256 i = 0;i < balance; i++){
            uint256 tokenId = CrypDevsNFT.tokenOfOwnerByIndex(sender, i);
            if(!tokenIdsClaimed[tokenId]){
                amount+=1;
                tokenIdsClaimed[tokenId]=true;
            }
        }
        require(amount>0,"You have already claim all tokens");
        _mint(msg.sender,amount * tokensPerNFT);

    }

    //withdraw all ETH sent to this contract
    function withdraw() public onlyOwner{
        uint256 amount = address(this).balance;
        require(amount>0,"Nothing to withdraw");
        address _owner = owner();
        (bool sent,)=_owner.call{value:amount}("");
        require(sent,"Failed");
    }

    receive() external payable {}

    fallback() external payable {}

}