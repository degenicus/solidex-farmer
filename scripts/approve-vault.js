async function main() {
  const vaultAddress = '0x700ceEbB257779c3b1F8f203495f04CD80CeaD91';
  const ERC20 = await ethers.getContractFactory('contracts/ERC20.sol:ERC20');
  //const fUSDTAddress = '0x049d68029688eabf473097a2fc38ef61633a3c7a';
  const usdcSynLPAddress = '0xB1b3B96cf35435b2518093acD50E02fe03A0131f';
  const erc20 = await ERC20.attach(usdcSynLPAddress);
  const [deployer] = await ethers.getSigners();
  console.log(deployer.address);
  console.log(await erc20.allowance(deployer.address, vaultAddress));
  // await erc20.approve(vaultAddress, ethers.utils.parseEther('100'));
  // console.log('erc20 approved');
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
