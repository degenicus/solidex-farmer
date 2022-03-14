async function main() {
  const vaultAddress = '0xB722E7966bdA138079D5B61a03f4FB6c3906777C';
  const strategyAddress = '0x79c8CEC3EBf97006Ca98932D707b51D0ebBbF7aA';

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
