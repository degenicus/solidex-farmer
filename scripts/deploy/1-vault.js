async function main() {
  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');

  const wantAddress = '0x5A3AA3284EE642152D4a2B55BE1160051c5eB932';
  const tokenName = 'BEETS-fBEETS Solidex Crypt';
  const tokenSymbol = 'rfvAMM-BEETS-fBEETS';
  const depositFee = 0;
  const tvlCap = ethers.utils.parseEther('2000');
  const options = { gasPrice: 700000000000, gasLimit: 9000000 };

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
