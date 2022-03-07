async function main() {
  const vaultAddress = '0x1111738909bAbf09772A2F5e2EE97A4051189621';
  const strategyAddress = '0x44120f35E5c87E183fcA03Bd8b30F77F7B8596F2';

  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');
  const vault = Vault.attach(vaultAddress);

  const options = { gasPrice: 900000000000, gasLimit: 9000000 };
  await vault.initialize(strategyAddress, options);
  console.log('Vault initialized');
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
