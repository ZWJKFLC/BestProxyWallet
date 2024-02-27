// npx hardhat run scripts/sm_imp.js --network dev
// npx hardhat run scripts/sm_imp.js --network hardhat
// npx hardhat run scripts/sm_imp.js --network zhaomei
const hre = require("hardhat");
async function main() {
    var Factory = await ethers.deployContract("Factory");
    await Factory.waitForDeployment();
    {
        await owner.sendTransaction({
            to: firstadd,
            value: ethers.parseEther("0.01") // 0.01 ether
        })
        console.log(await Factory.showcode());
        console.log(await Factory.showcodehash());
        console.log(await Factory.showflag());
        console.log(await Factory.showflag2());
        await Factory.deployContract();
        console.log(await Factory.showcode());
        console.log(await Factory.showcodehash());
        console.log(await Factory.showflag());
        console.log(await Factory.showflag2());
        return
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});