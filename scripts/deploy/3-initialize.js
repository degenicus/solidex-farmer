async function main() {
  const vaultAddress = '0xBd8523F4c1c558942622829B0a29E537aEbA2c2f';
  const strategyAddress = '0xE64dbC03C0e61347D1a213486777860c2b142015';

  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');
  const vault = Vault.attach(vaultAddress);

  const options = { gasPrice: 600000000000, gasLimit: 9000000 };
  await vault.initialize(strategyAddress, options);
  console.log('Vault initialized');
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
