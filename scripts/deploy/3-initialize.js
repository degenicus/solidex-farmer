async function main() {
  const vaultAddress = '0x582764C906635ED6B6b41902ec37f31F5ea206Da';
  const strategyAddress = '0x0bB700d297C9e8e94eaf68Af7573a855B3f3403D';

  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');
  const vault = Vault.attach(vaultAddress);

  const options = { gasPrice: 800000000000, gasLimit: 9000000 };
  await vault.initialize(strategyAddress, options);
  console.log('Vault initialized');
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
