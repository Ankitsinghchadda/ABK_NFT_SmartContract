const { ethers, network, run } = require("hardhat")
const {
    VERIFICATION_BLOCK_CONFIRMATIONS,
    networkConfig,
    developmentChains,
} = require("../../helper-hardhat-config")

async function deployNFTMarketplace(chainId) {
    //set log level to ignore non errors
    ethers.utils.Logger.setLogLevel(ethers.utils.Logger.levels.ERROR)

    const accounts = await ethers.getSigners()
    const deployer = accounts[0]

    let NftMarketplace
    let NftMarketplaceAddress
    let NFT
    let NFTAddress

    if (chainId == 31337) {
        const NftMarketplaceFactory = await ethers.getContractFactory("NftMarketplace")
        NftMarketplace = await NftMarketplaceFactory.connect(deployer).deploy()
        NftMarketplaceAddress = NftMarketplace.address

        const NFTFactory = await ethers.getContractFactory("BasicNft")
        NFT = await NFTFactory.connect(deployer).deploy()
        NFTAddress = NFT.address
    }

    const waitBlockConfirmations = developmentChains.includes(network.name)
        ? 1
        : VERIFICATION_BLOCK_CONFIRMATIONS
    await NftMarketplace.deployTransaction.wait(waitBlockConfirmations)

    console.log(`NFT Marketplace Deployed to  ${NftMarketplaceAddress} on ${network.name}`)

    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        await run("verify:verify", {
            address: NftMarketplaceAddress,
        })
        await run("verify:verify", {
            address: NFTAddress,
        })
    }
}

module.exports = {
    deployNFTMarketplace,
}
