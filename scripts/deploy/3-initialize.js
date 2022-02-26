async function main() {
  const vaultAddress = '0xC9101A4315b43C060F2e53715eFC32f9F13cf3Ff';
  const strategyAddress = '0xB8Ac7f8e7f328aE897a38726a5ED44326CD33773';

  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');
  const vault = Vault.attach(vaultAddress);

  //const options = { gasPrice: 2000000000000, gasLimit: 9000000 };
  await vault.initialize(strategyAddress);
  console.log('Vault initialized');
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
