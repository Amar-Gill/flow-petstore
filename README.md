Based on [this tutorial](https://nftschool.dev/tutorial/flow-nft-marketplace/#building-pet-store) from NFT School.

### TLDR

- basic React project bootstrapped with Vite
- basic NFT store using Flow blockchain

### Operation

- make sure project is a flow project with a valid `flow.json` - by running `flow init`
- start emulator `flow emulator`
- deploy contract `flow project deploy`
- mint NFT to emulator-account storage `flow transactions send src/flow/transactions/MintToken.cdc <json-metadata>`
- generate public-private key pair with `flow keys generate` and save into `.keys.json` for later reference
- create a new account `flow accounts create —-key <PUBLIC_KEY> --signer emulator-account`
