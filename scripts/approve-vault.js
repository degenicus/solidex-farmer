async function main() {
  const vaultAddress = '0xc2Bc6EDaa1D002AbC74c6197b3e0F5b850269DBF';
  const ERC20 = await ethers.getContractFactory('contracts/ERC20.sol:ERC20');
  const erc20 = await ERC20.attach('0x6B987e02Ca5eAE26D8B2bCAc724D4e03b3B0c295');
  const [deployer] = await ethers.getSigners();
  console.log(await erc20.balanceOf(deployer.address));
  // console.log('erc20 approved');
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
