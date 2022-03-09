async function main() {
  const vaultAddress = '0x7f5F4A1ac36aE29824687B7bA832A1D73B7C6B55';
  const strategyAddress = '0x9b857f4eC1376eDE56b1910C1C506aC80aa849C5';

  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');
  const vault = Vault.attach(vaultAddress);

  const options = { gasPrice: 500000000000, gasLimit: 9000000 };
  await vault.initialize(strategyAddress, options);
  console.log('Vault initialized');
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
