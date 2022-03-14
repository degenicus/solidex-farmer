async function main() {
  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');

  const wantAddress = '0x5821573d8F04947952e76d94f3ABC6d7b43bF8d0';
  const tokenName = 'USDC-DEI Solidex Crypt';
  const tokenSymbol = 'rfsAMM-USDC-DEI';
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
