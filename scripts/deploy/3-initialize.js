async function main() {
  const vaultAddress = '0xF01e863F145839ef35376998cc8F215832cfe6b5';
  const strategyAddress = '0xb299765Bbc0d6a3a54487eD470cebA7889984941';

  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');
  const vault = Vault.attach(vaultAddress);

  const options = { gasPrice: 2000000000000, gasLimit: 9000000 };
  await vault.initialize(strategyAddress, options);
  console.log('Vault initialized');
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
