async function main() {
  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');
  const wantAddress = '0x86dD79265814756713e631Dde7E162bdD538b7B1';
  const tokenName = 'Solidex WFTM-SCREAM Crypt';
  const tokenSymbol = 'rfvAMM-WFTM-SCREAM';
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
