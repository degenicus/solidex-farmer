async function main() {
  const vaultAddress = '0x7FE0286fb990c101E7a6727Dd72Bd57B9BfCcc33';
  const strategyAddress = '0xaAB8369086AFC5B8Dc5152fd099138c8bac2a86A';

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
