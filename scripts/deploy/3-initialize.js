async function main() {
  const vaultAddress = '0x85E8D9fFDB239E1A1a81F1a042d0415590D312Cd';
  const strategyAddress = '0x54309cf6fBAAC694b40c34fD7893c3a35bf03f0a';

  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');
  const vault = Vault.attach(vaultAddress);

  const options = { gasPrice: 700000000000, gasLimit: 9000000 };
  await vault.initialize(strategyAddress, options);
  console.log('Vault initialized');
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
