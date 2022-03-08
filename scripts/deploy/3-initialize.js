async function main() {
  const vaultAddress = '0xF242E207f13c09d2f59cC185e50479BB5e4E27c3';
  const strategyAddress = '0x796a2166be078D8AebBDf2ccBA8C2C2385adA833';

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
