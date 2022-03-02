async function main() {
  const solidProxy = '0xd9967ce4ABf017d01f456Afa68a748121678B86e';
  const stratFactory = await ethers.getContractFactory('ReaperAutoCompoundSolidexFarmer');
  const stratContract = await hre.upgrades.upgradeProxy(solidProxy, stratFactory, {
    call: { fn: 'clearUpgradeCooldown' },
  });
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
