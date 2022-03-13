async function main() {
  const vaultAddress = '0xC50A0D2dE513e1Cc4509F0ee99910dC45431DFBe';
  const strategyAddress = '0xdA2dc107458868824522de760e5A354D4EfD669f';

  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');
  const vault = Vault.attach(vaultAddress);

  const options = { gasPrice: 300000000000, gasLimit: 9000000 };
  await vault.initialize(strategyAddress, options);
  console.log('Vault initialized');
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
