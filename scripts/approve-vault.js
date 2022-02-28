async function main() {
  const vaultAddress = '0x3858F7D966D4044E4a42F0d4fd98B2dd87eB0c30';
  const ERC20 = await ethers.getContractFactory('contracts/ERC20.sol:ERC20');
  const usdcMimLPAddress = '0xbcab7d083Cf6a01e0DdA9ed7F8a02b47d125e682';
  const erc20 = await ERC20.attach(usdcMimLPAddress);
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
