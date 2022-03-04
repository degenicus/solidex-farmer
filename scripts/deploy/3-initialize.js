async function main() {
  const vaultAddress = '0x5793b4e188505036FcE3368194Fd83BA3eb848FE';
  const strategyAddress = '0x11fE19404dDb6b95b765a2667F583dCF70d13725';

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
