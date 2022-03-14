async function main() {
  const vaultAddress = '0xA3480E558590Ae032A306eaB08d099b3F71ec034';
  const strategyAddress = '0xA02C92F5cF566C807EDD9edda37669bdf4230D7B';

  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');
  const vault = Vault.attach(vaultAddress);

  const options = { gasPrice: 1000000000000, gasLimit: 9000000 };
  await vault.initialize(strategyAddress, options);
  console.log('Vault initialized');
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
