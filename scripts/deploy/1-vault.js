async function main() {
  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');

  const wantAddress = '0xF42dBcf004a93ae6D5922282B304E2aEFDd50058';
  const tokenName = 'DEI-DEUS Solidex Crypt';
  const tokenSymbol = 'rfvAMM-DEI-DEUS';
  const depositFee = 0;
  const tvlCap = ethers.utils.parseEther('2000');
  const options = { gasPrice: 300000000000, gasLimit: 9000000 };

  const vault = await Vault.deploy(wantAddress, tokenName, tokenSymbol, depositFee, tvlCap, options);

  await vault.deployed();
  console.log('Vault deployed to:', vault.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
