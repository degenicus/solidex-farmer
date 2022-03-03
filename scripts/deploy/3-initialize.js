async function main() {
  const vaultAddress = '0xc2Bc6EDaa1D002AbC74c6197b3e0F5b850269DBF';
  const strategyAddress = '0xf9D0771d83856Be7Ab6209D28055f76C5Df16bD7';

  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');
  const vault = Vault.attach(vaultAddress);

  const options = { gasPrice: 3000000000000, gasLimit: 9000000 };
  await vault.initialize(strategyAddress, options);
  console.log('Vault initialized');
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
