// npx hardhat run scripts/onetest.js --network dev
// npx hardhat run scripts/onetest.js --network hardhat
// npx hardhat run scripts/onetest.js --network zhaomei
const hre = require("hardhat");
// const { writer_info, writer_info_all, writer_info_all_proxy } = require('../tool/hh_log.js');
// const { hardhattool } = require('ethtool');
const { writer_info, writer_info_all, writer_info_all_proxy, getcontractinfo } = require('ethtool');
// const { getcontractinfo } = require('../tool/id-readcontracts');
var contractinfo = new Object();
async function main() {
    var [owner, addr1, addr2] = await ethers.getSigners();
    var Imputations = await ethers.deployContract("Imputations", [owner.address]);
    await Imputations.waitForDeployment();
    await writer_info_all(
        network,
        await artifacts.readArtifact("Imputations"),
        Imputations, [owner.address]
    );

    console.log("Imputations end");
    console.log("\nnpx hardhat verify ", Imputations.target, `--constructor-args ./Arguments/${network.name}/Imputations.json`, "--network ", network.name);
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