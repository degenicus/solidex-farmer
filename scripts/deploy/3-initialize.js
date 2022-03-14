async function main() {
  const vaultAddress = '0x6a9ad78519d15F0A130b23841CA01852648e0100';
  const strategyAddress = '0x1bFf94F3070FC29529a1444AaA5B942FD219A411';

  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');
  const vault = Vault.attach(vaultAddress);
  const options = { gasPrice: 200000000000, gasLimit: 9000000 };

  await vault.initialize(strategyAddress, options);
  console.log('Vault initialized');
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
