# Tigers Journey To The Moon NFT Smart Contract

### Pre-requisites

* Node v14.16.0

## Setup Process

1. Clone the repo and cd to the project directory.

2. Install dependencies
    ```
    npm i
    ```

3. Setup .env file
    ```
    cp .env.example .env
    ```
    Update config variables from the .env file as per your environment.
    ```
    MNENOMIC            # MNEMONIC/Private key of your wallet
    ETHERSCAN_API_KEY   # Needed to verify contract
    INFURA_PROJECT_ID   # Needed for eth node connection
    ```

4. To compile and deploy contracts
    ```
    # Deploy on Rinkeby Testnet
    npx truffle compile
    npx truffle migrate --reset --network=rinkeby

    # Deploy on Mainnet
    npx truffle compile
    npx truffle migrate --reset --network=mainnet
    ```

5. To verify the smart contract using truffle and bscscan API -
    ```
    # Verify on Rinkeby testnet
    npx truffle run verify {TokenContractName}@{DeployedAddress} --network=rinkeby

    # Verify on mainnet
    npx truffle run verify {TokenContractName}@{DeployedAddress} --network=mainnet
    ```

5. To run unit test from `/test` directory -
    ```
    npx truffle test
    ```

You may wish to use the ABI of the deployed contracts in your frontend application, those you will find in directory `/build` after running the `npx truffle migrate --reset --network=<network>` script in step 4.