async function main() {
  const vaultAddress = '0x6adfc4Ad341441E2b5459114dD988573923981fA';
  const ERC20 = await ethers.getContractFactory('contracts/ERC20.sol:ERC20');
  const erc20 = await ERC20.attach('0x5804F6C40f44cF7593F73cf3aa16F7037213A623');
  const [deployer] = await ethers.getSigners();
  console.log(await erc20.allowance(deployer.address, vaultAddress));
  await erc20.approve(vaultAddress, ethers.constants.MaxUint256);
  console.log('erc20 approved');
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
