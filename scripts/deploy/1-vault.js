async function main() {
  const Vault = await ethers.getContractFactory('ReaperVaultv1_3');

  const usdcSynLPAddress = '0xB1b3B96cf35435b2518093acD50E02fe03A0131f';
  const wantAddress = usdcSynLPAddress;
  const tokenName = 'Solidex USDC-SYN Crypt';
  const tokenSymbol = 'rfvAMM-USDC-SYN';
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
