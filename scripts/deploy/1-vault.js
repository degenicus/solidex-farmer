async function main() {
  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');

  const wftmMultiLPAddress = '0x94bE7e51efE2A0C06c2281b6b385FCD12C84d6F9';
  const wantAddress = wftmMultiLPAddress;
  const tokenName = 'Solidex WFTM-MULTI Crypt';
  const tokenSymbol = 'rfvAMM-WFTM-MULTI';
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
