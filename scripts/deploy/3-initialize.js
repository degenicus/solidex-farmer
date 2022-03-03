async function main() {
  const vaultAddress = '0xEf8D31Bb47fc1015B73D258bDbd7D68D26741f52';
  const strategyAddress = '0x71D3191daA12Db0924550d39199f7681A5378E1C';

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
