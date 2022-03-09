async function main() {
  const vaultAddress = '0xb5c492944f08C64974568A06271910880C4108C6';
  const strategyAddress = '0xfc118182065FE337C56bA8145947A8D772d0a477';

  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');
  const vault = Vault.attach(vaultAddress);

  const options = { gasPrice: 400000000000, gasLimit: 9000000 };
  await vault.initialize(strategyAddress, options);
  console.log('Vault initialized');
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
