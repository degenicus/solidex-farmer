async function main() {
  const vaultAddress = '0xbe722905A81749DC99CCf7335F1B70ae6a3E9089';
  const strategyAddress = '0xd9967ce4ABf017d01f456Afa68a748121678B86e';

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
