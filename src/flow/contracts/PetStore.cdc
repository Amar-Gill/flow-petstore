pub contract PetStore {

    // An array that stores NFT owners
    pub var owners: {UInt64: Address}

    pub resource NFT {

        // Unique ID for each NFT
        pub let id: UInt64

        // String mapping to hold metadata
        pub(set) var metadata: {String: String}

        // Constructor method
        init(id: UInt64, metadata: {String: String}) {
            self.id = id
            self.metadata = metadata
        }
    }

    // @TODO might not want to expose withdraw / updateTokenMetadata functions
    pub resource interface NFTReceiver {

        // Withdraw a token by its ID and returns the token.
        pub fun withdraw(id: UInt64): @NFT

        // Deposit an NFT to this NFTReceiver instance.
        pub fun deposit(token: @NFT)

        // Get all NFT IDs belonging to this NFTReceiver instance.
        pub fun getTokenIds(): [UInt64]

        // Get the metadata of an NFT instance by its ID.
        pub fun getTokenMetadata(id: UInt64) : {String: String}

        // Update the metadata of an NFT.
        pub fun updateTokenMetadata(id: UInt64, metadata: {String: String})
    }

    pub resource NFTCollection: NFTReceiver {

        // Keeps track of NFTs this collection.
        access(account) var ownedNFTs: @{UInt64: NFT}

        // Constructor
        init() {
            self.ownedNFTs <- {}
        }

        // Destructor
        destroy() {
            destroy self.ownedNFTs
        }

        // Withdraws and return an NFT token.
        pub fun withdraw(id: UInt64): @NFT {
            let token <- self.ownedNFTs.remove(key: id)
            return <- token!
        }

        // Deposits a token to this NFTCollection instance.
        pub fun deposit(token: @NFT) {
            self.ownedNFTs[token.id] <-! token
        }

        // Returns an array of the IDs that are in this collection.
        pub fun getTokenIds(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // Returns the metadata of an NFT based on the ID.
        pub fun getTokenMetadata(id: UInt64): {String : String} {
            let metadata = self.ownedNFTs[id]?.metadata
            return metadata!
        }

        // Updates the metadata of an NFT based on the ID.
        pub fun updateTokenMetadata(id: UInt64, metadata: {String: String}) {
            let nftRef <- self.ownedNFTs.remove(key: id)

            for key in metadata.keys {
                nftRef?.metadata?.insert(key: key,  metadata[key]!)
            }

            self.ownedNFTs[id] <-! nftRef
        }
    }

    // Public factory method to create a collection
    // so it is callable from the contract scope.
    pub fun createNFTCollection(): @NFTCollection {
        return <- create NFTCollection()
    }

    pub resource NFTMinter {

        // Declare a global variable to count ID.
        pub var idCount: UInt64

        init() {
            // Instantialize the ID counter.
            self.idCount = 1
        }

        pub fun mint(_ metadata: {String: String}): @NFT {

            // Create a new @NFT resource with the current ID.
            let token <- create NFT(id: self.idCount, metadata: metadata)

            // Save the current owner's address to the dictionary.
            PetStore.owners[self.idCount] = PetStore.account.address

            // Increment the ID
            self.idCount = self.idCount + 1 as UInt64

            return <-token
        }
    }

    // This contract constructor is called once when the contract is deployed.
    // It does the following:
    //
    // - Creating an empty Collection for the deployer of the collection so
    //   the owner of the contract can mint and own NFTs from that contract.
    //
    // - The `Collection` resource is published in a public location with reference
    //   to the `NFTReceiver` interface. This is how we tell the contract that the functions defined
    //   on the `NFTReceiver` can be called by anyone.
    //
    // - The `NFTMinter` resource is saved in the account storage for the creator of
    //   the contract. Only the creator can mint tokens.
    init() {
        // Set `owners` to an empty dictionary.
        self.owners = {}

        // Create a new `@NFTCollection` instance and save it in `/storage/NFTCollection` domain,
        // which is only accessible by the contract owner's account.
        self.account.save(<-create NFTCollection(), to: /storage/NFTCollection)

        // "Link" only the `@NFTReceiver` interface from the `@NFTCollection` stored at `/storage/NFTCollection` domain
        // to the `/public/NFTReceiver` domain, which is accessible to any user.
        self.account.link<&{NFTReceiver}>(/public/NFTReceiver, target: /storage/NFTCollection)

        // Create a new `@NFTMinter` instance and save it in `/storage/NFTMinter` domain, accesible
        // only by the contract owner's account.
        self.account.save(<-create NFTMinter(), to: /storage/NFTMinter)
    }
}
 