async function main() {
  const vaultAddress = '0x6adfc4Ad341441E2b5459114dD988573923981fA';
  const strategyAddress = '0x0790D1d0054d92124Eef42D0501bA45054B439c7';

  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');
  const vault = Vault.attach(vaultAddress);

  await vault.initialize(strategyAddress);
  console.log('Vault initialized');
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
