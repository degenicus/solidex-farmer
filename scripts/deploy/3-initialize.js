async function main() {
  const vaultAddress = '0xDBd5d44f9b0ded11Ada7fefD96A9f2ac80B9FDC3';
  const strategyAddress = '0x4201597B169d29E5452131B2fC41C52CFfA4991f';

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
