// npx hardhat run scripts/Imputation.js --network dev
// npx hardhat run scripts/Imputation.js --network hardhat
// npx hardhat run scripts/Imputation.js --network zhaomei
const hre = require("hardhat");
// const { writer_info, writer_info_all, writer_info_all_proxy } = require('../tool/hh_log.js');
// const { hardhattool } = require('ethtool');
const { writer_info, writer_info_all, writer_info_all_proxy, getcontractinfo } = require('ethtool');
// const { getcontractinfo } = require('../tool/id-readcontracts');
var contractinfo = new Object();
async function main() {
    var [owner, addr1, addr2] = await ethers.getSigners();
    var Imputation = await ethers.deployContract("Imputation", [owner.address]);
    await Imputation.waitForDeployment();
    await writer_info_all(
        network,
        await artifacts.readArtifact("Imputation"),
        Imputation, [owner.address]
    );

    console.log("Imputation end");
    console.log("\nnpx hardhat verify ", Imputation.target, `--constructor-args ./Arguments/${network.name}/Imputation.json`, "--network ", network.name);
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