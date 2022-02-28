async function main() {
  const vaultAddress = '0xbe722905A81749DC99CCf7335F1B70ae6a3E9089';
  const ERC20 = await ethers.getContractFactory('contracts/ERC20.sol:ERC20');
  const ftmTombAddress = '0x60a861Cd30778678E3d613db96139440Bd333143';
  const erc20 = await ERC20.attach(ftmTombAddress);
  const [deployer] = await ethers.getSigners();
  console.log(await erc20.allowance(deployer.address, vaultAddress));
  //await erc20.approve(vaultAddress, ethers.utils.parseEther('100'));
  // console.log('erc20 approved');
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
