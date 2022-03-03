async function main() {
  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');

  const wftmCrvAddress = '0xED7Fd242ce91a541ABcaE52f3d617dacA7fe6e34';
  const wantAddress = wftmCrvAddress;
  const tokenName = 'Solidex WFTM-CRV Crypt';
  const tokenSymbol = 'rfvAMM-WFTM-CRV';
  const depositFee = 0;
  const tvlCap = ethers.utils.parseEther('2000');

  const vault = await Vault.deploy(wantAddress, tokenName, tokenSymbol, depositFee, tvlCap);

  await vault.deployed();
  console.log('Vault deployed to:', vault.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
