const TJTTM = artifacts.require("TJTTM");
const TJTTMAirdrop = artifacts.require("TJTTMAirdrop");

module.exports = async function (deployer) {

    // Token deploy
    await deployer.deploy(TJTTM, "https://google.com/");
    const deployedTJTTM = await TJTTM.deployed();

    // Airdrop contract deploy
    await deployer.deploy(TJTTMAirdrop);
    const deployedAirdropContract = await TJTTMAirdrop.deployed();

    // Operations post deployment

    // 1. Approval to airdrop contract
    await deployedTJTTM.setApprovalForAll(deployedAirdropContract.address, true);

};
