import { ethers } from "hardhat";
import "dotenv/config";

const {CRYPTO_DEVS_NFT_CONTRACT}=require("../constants");

async function main() {
  const crytpdevNFTContract = CRYPTO_DEVS_NFT_CONTRACT;

  const CryptoERC20 = await ethers.getContractFactory("CryptoERC20");
  const cryptotoken = await CryptoERC20.deploy(crytpdevNFTContract);

  await cryptotoken.deployed();

  console.log(
    `CryptoERC20 deployed to ${cryptotoken.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
