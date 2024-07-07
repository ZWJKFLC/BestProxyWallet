// npx hardhat run scripts/t_imp.js --network dev
// npx hardhat run scripts/t_imp.js --network hardhat
// npx hardhat run scripts/t_imp.js --network zhaomei
const hre = require("hardhat");
async function main() {
    var [owner, addr1, addr2] = await ethers.getSigners();
    // console.log(owner.address, " ", await ethers.provider.getBalance(owner.address));
    // return
    var Imputation = await ethers.deployContract("Imputation", [owner.address]);
    await Imputation.waitForDeployment();
    var token = await ethers.deployContract("Token");
    await token.waitForDeployment();
    let firstadd = await Imputation.getwalletadd(1);
    // {
    //     console.log("//token test");
    //     console.log("firstadd:", firstadd, " tokenbalance:", await token.balanceOf(firstadd));
    //     console.log("owner:", firstadd, " tokenbalance:", await token.balanceOf(owner));
    //     await token.transfer(firstadd, decimal2big(token, 1))
    //     console.log("transfer end");
    //     console.log("firstadd:", firstadd, " tokenbalance:", await token.balanceOf(firstadd));
    //     console.log("owner:", firstadd, " tokenbalance:", await token.balanceOf(owner));
    //     await Imputation.imputationtoken([1], token.target);
    //     console.log("imputationtoken end");
    //     console.log("firstadd:", firstadd, " tokenbalance:", await token.balanceOf(firstadd));
    //     console.log("owner:", firstadd, " tokenbalance:", await token.balanceOf(owner));
    // }
    // {
    //     console.log("//eth test");
    //     console.log("firstadd:", firstadd, " ethbalance:", await ethers.provider.getBalance(firstadd));
    //     console.log("owner:", firstadd, " ethbalance:", await ethers.provider.getBalance(owner));
    //     await owner.sendTransaction({
    //         to: firstadd,
    //         value: ethers.parseEther("0.01") // 0.01 ether
    //     })
    //     console.log("sendTransaction end");
    //     console.log("firstadd:", firstadd, " ethbalance:", await ethers.provider.getBalance(firstadd));
    //     console.log("owner:", firstadd, " ethbalance:", await ethers.provider.getBalance(owner));
    //     await Imputation.imputationeth([1]);
    //     console.log("imputationeth end");
    //     console.log("firstadd:", firstadd, " ethbalance:", await ethers.provider.getBalance(firstadd));
    //     console.log("owner:", firstadd, " ethbalance:", await ethers.provider.getBalance(owner));
    // }
    // return
    {
        await owner.sendTransaction({
            to: firstadd,
            value: ethers.parseEther("0.01") // 0.01 ether
        })
        console.log(
            "\nbalance: ", await ethers.provider.getBalance(firstadd),
        );
        await Imputation.imputationeth([1]);
        var Walletlogic = new ethers.Contract(
            firstadd,
            (await artifacts.readArtifact("Walletlogic")).abi,
            owner
        );
        var WalletProxy = new ethers.Contract(
            firstadd,
            (await artifacts.readArtifact("WalletProxy")).abi,
            owner
        );
        console.log(
            "\naddress: ", firstadd,
            "\nbalance: ", await ethers.provider.getBalance(firstadd),
            "\ntreasury: ", await Walletlogic.treasury(),
            "\nOwnable: ", await WalletProxy.owner(),
            "\nimplementation: ", await WalletProxy.implementation(),
            // "\n_implementation: ", await WalletProxy._implementation(),
            "\nthisaddress: ", await WalletProxy.thisaddress(),

        );
    }

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}
function serializeBigInt(data) {
    return JSON.stringify(data, (_, value) =>
        typeof value === 'bigint'
            ? value.toString()
            : value
    );
}

async function decimal2big(token, value) {
    return BigInt(Math.floor(value * (10 ** Number(await token.decimals()))))
}
async function decimal2show(token, value) {
    return Math.floor(Number(value / (10n ** await token.decimals())))
}