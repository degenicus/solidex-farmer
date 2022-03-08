async function main() {
  const vaultAddress = '0x3DDA58660f658Efe48895F57e7Dc4bBF462557D9';
  const strategyAddress = '0x9b80A745e01989A49024B8EA754a57c1b374a279';

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
