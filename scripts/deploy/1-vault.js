async function main() {
  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');

  const ftmTombLPAddress = '0x60a861Cd30778678E3d613db96139440Bd333143';
  const wantAddress = ftmTombLPAddress;
  const tokenName = 'Solidex WFTM-TOMB Crypt';
  const tokenSymbol = 'rfvAMM-WFTM-TOMB';
  const depositFee = 0;
  const tvlCap = ethers.utils.parseEther('2000');

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
