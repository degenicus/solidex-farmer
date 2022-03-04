async function main() {
  const vaultAddress = '0x700ceEbB257779c3b1F8f203495f04CD80CeaD91';
  const strategyAddress = '0xd7c8CFF5e62DDea98F692B210C302a4DF312cf04';

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
