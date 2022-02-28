async function main() {
  const vaultAddress = '0x3858F7D966D4044E4a42F0d4fd98B2dd87eB0c30';
  const strategyAddress = '0x0D3381C9579D25812a61Df7990E9e221531FC2d9';

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
