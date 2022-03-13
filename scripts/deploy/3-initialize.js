async function main() {
  const vaultAddress = '0x2C285E7cF6752a8784FDeA7748deA624d9cF6e9C';
  const strategyAddress = '0x5beb4A4a2dC745D2E0d20ef84B523B465f1Eb5b6';

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
