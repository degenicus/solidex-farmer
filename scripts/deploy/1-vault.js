async function main() {
  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');

  //const ftmTombLPAddress = '0x60a861Cd30778678E3d613db96139440Bd333143';
  const usdcMimLPAddress = '0xbcab7d083Cf6a01e0DdA9ed7F8a02b47d125e682';
  const wantAddress = usdcMimLPAddress;
  const tokenName = 'Solidex USDC-MIM Crypt';
  const tokenSymbol = 'rfsAMM-USDC-MIM';
  const depositFee = 0;
  const tvlCap = ethers.utils.parseEther('0.002');

  const vault = await Vault.deploy(wantAddress, tokenName, tokenSymbol, depositFee, tvlCap);

  await vault.deployed();
  console.log('Vault deployed to:', vault.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
