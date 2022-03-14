async function main() {
  const vaultAddress = '0x33462eae91e9dEB43a9aF50f3A5ae50E7d46FC69';
  const strategyAddress = '0x5CcEdedb013A37fAE9dC332130396eEA80f3165d';

  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');
  const vault = Vault.attach(vaultAddress);

  const options = { gasPrice: 300000000000, gasLimit: 9000000 };
  await vault.initialize(strategyAddress, options);
  console.log('Vault initialized');
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
