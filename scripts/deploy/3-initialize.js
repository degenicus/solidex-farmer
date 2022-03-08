async function main() {
  const vaultAddress = '0xA6582A0EB4155E81Dbe8934F8bB5F3eaca8BF371';
  const strategyAddress = '0xDc0eCC1e151a6Fab216F169738a1e4ABf42f88c6';

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
