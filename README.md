Based on [this tutorial](https://nftschool.dev/tutorial/flow-nft-marketplace/#building-pet-store) from NFT School.

### TLDR

- basic React project bootstrapped with Vite
- basic NFT store using Flow blockchain

### Operation

- project root contains a `flow.json` file indicating that this is a flow project - generated via `flow init`
- start emulator `flow emulator`
- deploy contract `flow project deploy`
- mint NFT to emulator-account storage `flow transactions send src/flow/transactions/MintToken.cdc <json-metadata>`
- generate public-private key pair for a new account with `flow keys generate` and save both keys into `.keys.txt` for later reference
- create a new account `flow accounts create —-key <PUBLIC_KEY> --signer emulator-account`
  - take note of the address
- save the account address / private key in the `accounts` property of `flow.json` as `test-account`
- initialize an NFT collection for the new account with `flow transactions send src/flow/transaction/InitCollection.cdc --signer test-account`
- send the NFT to the test-account collection from the emulator-account collection
  - `flow transactions send src/flow/transaction/TransferToken.cdc 1 <test-account-address>`
  - the NFT id is 1 because we only the `MintToken.cdc` transaction once
  - WIP: this txn is erroring. May need to implement updateOwners method on NFTReceiver interface
  - error: cannot mutate `owners`: field is only mutable inside `PetStore`
