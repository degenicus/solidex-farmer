async function main() {
  const vaultAddress = '0xd2Ed1D0B2a7c6a0bAafbDf70F1d6bf7fE5020a38';
  const strategyAddress = '0xE4791818ce288Df603301649bCB012134C043d20';

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
