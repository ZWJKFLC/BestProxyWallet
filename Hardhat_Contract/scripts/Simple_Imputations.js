// npx hardhat run scripts/Simple_Imputations.js --network dev
// npx hardhat run scripts/Simple_Imputations.js --network hardhat
// npx hardhat run scripts/Simple_Imputations.js --network zhaomei
const hre = require("hardhat");
var contractinfo = new Object();
async function main() {
    var [owner, addr1, addr2] = await ethers.getSigners();
    var Simple_Imputations = await ethers.deployContract("Simple_Imputations", [owner.address]);
    await Simple_Imputations.waitForDeployment();
    await writer_info_all(
        network,
        await artifacts.readArtifact("Simple_Imputations"),
        Simple_Imputations, [owner.address]
    );

    console.log("Simple_Imputations end");
    console.log("\nnpx hardhat verify ", Simple_Imputations.target, `--constructor-args ./Arguments/${network.name}/Simple_Imputations.json`, "--network ", network.name);
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