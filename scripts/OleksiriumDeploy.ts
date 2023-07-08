import { ethers } from "hardhat";
import { Oleksirium__factory } from "../typechain-types";

async function main() {
    const [signer] = await ethers.getSigners();
    const Oleksirium = await new Oleksirium__factory(signer).deploy("Oleksirium", "OLKS", "0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419");

    console.log(Oleksirium.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
