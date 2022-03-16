async function main() {
  const vaultAddress = '0x8E5CE789F631D496a06a83778A551802032a647a';
  const strategyAddress = '0x9e95f1b498283340f8357Eac5b412965f5886c12';

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
