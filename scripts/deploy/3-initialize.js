async function main() {
  const vaultAddress = '0x67A298032b714D01670B7f65e64EEFcAcA7Be529';
  const strategyAddress = '0x08BF5Ace4b81053ef46Db79AfE159fF6c94E026B';

  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');
  const vault = Vault.attach(vaultAddress);

  const options = { gasPrice: 350000000000, gasLimit: 9000000 };
  await vault.initialize(strategyAddress, options);
  console.log('Vault initialized');
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
