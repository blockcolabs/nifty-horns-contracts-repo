/*
 * Nifty Horns Smart Contract
 *
 * The CardType struct contains a card type ID and a metadata string. For
 * example, a metadata string may contain the following fields:
 *  - Player name
 *  - Image URL
 *  - Edition type (e.g. Standard, Collector, Ultimate)
 *
 * The CardData struct contains a card type ID and a serial number. It
 * represents a card of the specified card type. The CardData is used for
 * minting card NFTs.
 *
 * The Series integer is an incrementing number. Each series can contain
 * multiple drops.
 *
 * The Drop resource is used to facilitate a drop. It is described by a name
 * (e.g. Red River Showdown). It contains functions to add and remove card types
 * from a drop and to mint cards.
 * 
 * The Admin resource has the power to perform all of the important actions in
 * the smart contract.
 *
 * The Collection resource contains an array of card NFTs.
 */

import NonFungibleToken from 0xNFTADDRESS

pub contract NiftyHorns: NonFungibleToken {

    // -----------------------------------------------------------------------
    // Nifty Horns contract Events
    // -----------------------------------------------------------------------

    // Emitted when the Nifty Horns contract is created
    pub event ContractInitialized()

    // Emitted when a new CardType struct is created
    pub event CardTypeCreated(id: UInt32, metadata: {String:String})
    // Emitted when a new series has been triggered by an admin
    pub event NewSeriesStarted(newCurrentSeries: UInt32)

    // Events for Drop-Related actions
    //
    // Emitted when a new Drop is created
    pub event DropCreated(dropID: UInt32, series: UInt32)
    // Emitted when a new CardType is added to a Drop
    pub event CardTypeAddedToDrop(dropID: UInt32, cardTypeID: UInt32)
    // Emitted when a CardType is retired from a Drop and cannot be used to mint
    pub event CardTypeRetiredFromDrop(dropID: UInt32, cardTypeID: UInt32, numCards: UInt32)
    // Emitted when a Drop is locked, meaning CardTypes cannot be added
    pub event DropLocked(dropID: UInt32)
    // Emitted when a Card is minted from a Drop
    pub event CardMinted(cardID: UInt64, cardTypeID: UInt32, dropID: UInt32, serialNumber: UInt32)

    // Events for Collection-related actions
    //
    // Emitted when a card is withdrawn from a Collection
    pub event Withdraw(id: UInt64, from: Address?)
    // Emitted when a card is deposited into a Collection
    pub event Deposit(id: UInt64, to: Address?)

    // Emitted when a Card is destroyed
    pub event CardDestroyed(id: UInt64)

    // -----------------------------------------------------------------------
    // Nifty Horns contract-level fields.
    // These contain actual values that are stored in the smart contract.
    // -----------------------------------------------------------------------

    // Series that this Drop belongs to.
    // Series is a concept that indicates a group of Drops through time.
    // Many Drops can exist at a time, but only one series.
    pub var currentSeries: UInt32

    // Variable size dictionary of CardType structs
    access(self) var cardTypeDatas: {UInt32: CardType}

    // Variable size dictionary of DropData structs
    access(self) var dropDatas: {UInt32: DropData}

    // Variable size dictionary of Drop resources
    access(self) var drops: @{UInt32: Drop}

    // The ID that is used to create CardTypes. 
    // Every time a CardType is created, cardTypeID is assigned 
    // to the new CardType's ID and then is incremented by 1.
    pub var nextCardTypeID: UInt32

    // The ID that is used to create Drops. Every time a Drop is created
    // dropID is assigned to the new drop's ID and then is incremented by 1.
    pub var nextDropID: UInt32

    // The total number of Nifty Horns Card NFTs that have been created
    // Because NFTs can be destroyed, it doesn't necessarily mean that this
    // reflects the total number of NFTs in existence, just the number that
    // have been minted to date. Also used as global card IDs for minting.
    pub var totalSupply: UInt64

    // -----------------------------------------------------------------------
    // Nifty Horns contract-level Composite Type definitions
    // -----------------------------------------------------------------------
    // These are just *definitions* for Types that this contract
    // and other accounts can use. These definitions do not contain
    // actual stored values, but an instance (or object) of one of these Types
    // can be created by this contract that contains stored values.
    // -----------------------------------------------------------------------

    // CardType is a Struct that holds metadata associated
    // with a specific Nifty Horns card type.
    //
    // Card NFTs will all reference a single cardType as the owner of
    // its metadata. The cardTypes are publicly accessible, so anyone can
    // read the metadata associated with a specific cardType ID.
    //
    pub struct CardType {

        // The unique ID for the CardType
        pub let cardTypeID: UInt32

        // Stores all the metadata about the cardType as a string mapping
        // This is not the long term way NFT metadata will be stored. It's a temporary
        // construct while we figure out a better way to do metadata.
        //
        pub let metadata: {String: String}

        init(metadata: {String: String}) {
            pre {
                metadata.length != 0: "New CardType metadata cannot be empty"
            }
            self.cardTypeID = NiftyHorns.nextCardTypeID
            self.metadata = metadata

            // Increment the ID so that it isn't used again
            NiftyHorns.nextCardTypeID = NiftyHorns.nextCardTypeID + UInt32(1)

            emit CardTypeCreated(id: self.cardTypeID, metadata: metadata)
        }
    }

    // A Drop is a grouping of CardTypes that have occured in the real world
    // that make up a related group of collectibles, like drops of baseball
    // or Magic cards. A CardType can exist in multiple different drops.
    // 
    // DropData is a struct that is stored in a field of the contract.
    // Anyone can query the constant information
    // about a drop by calling various getters located 
    // at the end of the contract. Only the admin has the ability 
    // to modify any data in the private Drop resource.
    //
    pub struct DropData {

        // Unique ID for the Drop
        pub let dropID: UInt32

        // Name of the Drop
        // ex. "Red River Shootout"
        pub let name: String

        // Series that this Drop belongs to.
        // Series is a concept that indicates a group of Drops through time.
        // Many Drops can exist at a time, but only one series.
        pub let series: UInt32

        init(name: String) {
            pre {
                name.length > 0: "New Drop name cannot be empty"
            }
            self.dropID = NiftyHorns.nextDropID
            self.name = name
            self.series = NiftyHorns.currentSeries

            // Increment the dropID so that it isn't used again
            NiftyHorns.nextDropID = NiftyHorns.nextDropID + UInt32(1)

            emit DropCreated(dropID: self.dropID, series: self.series)
        }
    }

    // Drop is a resource type that contains the functions to add and remove
    // CardTypes from a drop and mint Cards.
    //
    // It is stored in a private field in the contract so that
    // the admin resource can call its methods.
    //
    // The admin can add CardTypes to a Drop so that the drop can mint Cards
    // that reference that cardTypedata.
    // The Cards that are minted by a Drop will be listed as belonging to
    // the Drop that minted it, as well as the CardType it references.
    // 
    // Admin can also retire CardTypes from the Drop, meaning that the retired
    // CardType can no longer have Cards minted from it.
    //
    // If the admin locks the Drop, no more CardTypes can be added to it, but 
    // Cards can still be minted.
    //
    // If retireAll() and lock() are called back-to-back, 
    // the Drop is closed off forever and nothing more can be done with it.
    pub resource Drop {

        // Unique ID for the drop
        pub let dropID: UInt32

        // Array of cardTypes that are a part of this drop.
        // When a cardType is added to the drop, its ID gets appended here.
        // The ID does not get removed from this array when a CardType is retired.
        pub var cardTypes: [UInt32]

        // Map of CardType IDs that Indicates if a CardType in this Drop can be minted.
        // When a CardType is added to a Drop, it is mapped to false (not retired).
        // When a CardType is retired, this is drop to true and cannot be changed.
        pub var retired: {UInt32: Bool}

        // Indicates if the Drop is currently locked.
        // When a Drop is created, it is unlocked 
        // and CardTypes are allowed to be added to it.
        // When a drop is locked, CardTypes cannot be added.
        // A Drop can never be changed from locked to unlocked,
        // the decision to lock a Drop it is final.
        // If a Drop is locked, CardTypes cannot be added, but
        // Cards can still be minted from CardTypes
        // that exist in the Drop.
        pub var locked: Bool

        // Mapping of CardType IDs that indicates the number of Cards 
        // that have been minted for specific CardTypes in this Drop.
        // When a Card is minted, this value is stored in the Card to
        // show its place in the Drop, eg. 13 of 60.
        pub var numberMintedPerCardType: {UInt32: UInt32}

        init(name: String) {
            self.dropID = NiftyHorns.nextDropID
            self.cardTypes = []
            self.retired = {}
            self.locked = false
            self.numberMintedPerCardType = {}

            // Create a new DropData for this Drop and store it in contract storage
            NiftyHorns.dropDatas[self.dropID] = DropData(name: name)
        }

        // addCardType adds a cardType to the drop
        //
        // Parameters: cardTypeID: The ID of the CardType that is being added
        //
        // Pre-Conditions:
        // The CardType needs to be an existing cardType
        // The Drop needs to be not locked
        // The CardType can't have already been added to the Drop
        //
        pub fun addCardType(cardTypeID: UInt32) {
            pre {
                NiftyHorns.cardTypeDatas[cardTypeID] != nil: "Cannot add the CardType to Drop: CardType doesn't exist."
                !self.locked: "Cannot add the cardType to the Drop after the drop has been locked."
                self.numberMintedPerCardType[cardTypeID] == nil: "The cardType has already beed added to the drop."
            }

            // Add the CardType to the array of CardTypes
            self.cardTypes.append(cardTypeID)

            // Open the CardType up for minting
            self.retired[cardTypeID] = false

            // Initialize the Card count to zero
            self.numberMintedPerCardType[cardTypeID] = 0

            emit CardTypeAddedToDrop(dropID: self.dropID, cardTypeID: cardTypeID)
        }

        // addCardTypes adds multiple CardTypes to the Drop
        //
        // Parameters: cardTypeIDs: The IDs of the CardTypes that are being added
        //                      as an array
        //
        pub fun addCardTypes(cardTypeIDs: [UInt32]) {
            for cardType in cardTypeIDs {
                self.addCardType(cardTypeID: cardType)
            }
        }

        // retireCardType retires a CardType from the Drop so that it can't mint new Cards
        //
        // Parameters: cardTypeID: The ID of the CardType that is being retired
        //
        // Pre-Conditions:
        // The CardType is part of the Drop and not retired (available for minting).
        // 
        pub fun retireCardType(cardTypeID: UInt32) {
            pre {
                self.retired[cardTypeID] != nil: "Cannot retire the CardType: CardType doesn't exist in this drop!"
            }

            if !self.retired[cardTypeID]! {
                self.retired[cardTypeID] = true

                emit CardTypeRetiredFromDrop(dropID: self.dropID, cardTypeID: cardTypeID, numCards: self.numberMintedPerCardType[cardTypeID]!)
            }
        }

        // retireAll retires all the cardTypes in the Drop
        // Afterwards, none of the retired CardTypes will be able to mint new Cards
        //
        pub fun retireAll() {
            for cardType in self.cardTypes {
                self.retireCardType(cardTypeID: cardType)
            }
        }

        // lock() locks the Drop so that no more CardTypes can be added to it
        //
        // Pre-Conditions:
        // The Drop should not be locked
        pub fun lock() {
            if !self.locked {
                self.locked = true
                emit DropLocked(dropID: self.dropID)
            }
        }

        // mintCard mints a new Card and returns the newly minted Card
        // 
        // Parameters: cardTypeID: The ID of the CardType that the Card references
        //
        // Pre-Conditions:
        // The CardType must exist in the Drop and be allowed to mint new Cards
        //
        // Returns: The NFT that was minted
        // 
        pub fun mintCard(cardTypeID: UInt32): @NFT {
            pre {
                self.retired[cardTypeID] != nil: "Cannot mint the card: This cardType doesn't exist."
                !self.retired[cardTypeID]!: "Cannot mint the card from this cardType: This cardType has been retired."
            }

            // Gets the number of Cards that have been minted for this CardType
            // to use as this Card's serial number
            let numInCardType = self.numberMintedPerCardType[cardTypeID]!

            // Mint the new card
            let newCard: @NFT <- create NFT(serialNumber: numInCardType + UInt32(1),
                                              cardTypeID: cardTypeID,
                                              dropID: self.dropID)

            // Increment the count of Cards minted for this CardType
            self.numberMintedPerCardType[cardTypeID] = numInCardType + UInt32(1)

            return <-newCard
        }

        // batchMintCard mints an arbitrary quantity of Cards 
        // and returns them as a Collection
        //
        // Parameters: cardTypeID: the ID of the CardType that the Cards are minted for
        //             quantity: The quantity of Cards to be minted
        //
        // Returns: Collection object that contains all the Cards that were minted
        //
        pub fun batchMintCard(cardTypeID: UInt32, quantity: UInt64): @Collection {
            let newCollection <- create Collection()

            var i: UInt64 = 0
            while i < quantity {
                newCollection.deposit(token: <-self.mintCard(cardTypeID: cardTypeID))
                i = i + UInt64(1)
            }

            return <-newCollection
        }
    }

    pub struct CardData {

        // The ID of the Drop that the Card comes from
        pub let dropID: UInt32

        // The ID of the CardType that the Card references
        pub let cardTypeID: UInt32

        // The place in the edition that this Card was minted
        // Otherwise know as the serial number
        pub let serialNumber: UInt32

        init(dropID: UInt32, cardTypeID: UInt32, serialNumber: UInt32) {
            self.dropID = dropID
            self.cardTypeID = cardTypeID
            self.serialNumber = serialNumber
        }

    }

    // The resource that represents the Card NFTs
    //
    pub resource NFT: NonFungibleToken.INFT {

        // Global unique card ID
        pub let id: UInt64
        
        // Struct of Card metadata
        pub let data: CardData

        init(serialNumber: UInt32, cardTypeID: UInt32, dropID: UInt32) {
            // Increment the global Card IDs
            NiftyHorns.totalSupply = NiftyHorns.totalSupply + UInt64(1)

            self.id = NiftyHorns.totalSupply

            // Set the metadata struct
            self.data = CardData(dropID: dropID, cardTypeID: cardTypeID, serialNumber: serialNumber)

            emit CardMinted(cardID: self.id, cardTypeID: cardTypeID, dropID: self.data.dropID, serialNumber: self.data.serialNumber)
        }

        // If the Card is destroyed, emit an event to indicate 
        // to outside ovbservers that it has been destroyed
        destroy() {
            emit CardDestroyed(id: self.id)
        }
    }

    // Admin is a special authorization resource that 
    // allows the owner to perform important functions to modify the 
    // various aspects of the CardTypes, Drops, and Cards
    //
    pub resource Admin {

        // createCardType creates a new CardType struct 
        // and stores it in the CardTypes dictionary in the Nifty Horns smart contract
        //
        // Parameters: metadata: A dictionary mapping metadata titles to their data
        //                       example: {
        //                           "Player Name": "John Smith",
        //                           "Image URL": "https://ipfs.io/ipfs/<CID>",
        //                           "Edition": "Standard"
        //                       }
        //
        // Returns: the ID of the new CardType object
        //
        pub fun createCardType(metadata: {String: String}): UInt32 {
            // Create the new CardType
            var newCardType = CardType(metadata: metadata)
            let newID = newCardType.cardTypeID

            // Store it in the contract storage
            NiftyHorns.cardTypeDatas[newID] = newCardType

            return newID
        }

        // createDrop creates a new Drop resource and stores it
        // in the drops mapping in the Nifty Horns contract
        //
        // Parameters: name: The name of the Drop
        //
        pub fun createDrop(name: String) {
            // Create the new Drop
            var newDrop <- create Drop(name: name)

            // Store it in the drops mapping field
            NiftyHorns.drops[newDrop.dropID] <-! newDrop
        }

        // borrowDrop returns a reference to a drop in the Nifty Horns
        // contract so that the admin can call methods on it
        //
        // Parameters: dropID: The ID of the Drop that you want to
        // get a reference to
        //
        // Returns: A reference to the Drop with all of the fields
        // and methods exposed
        //
        pub fun borrowDrop(dropID: UInt32): &Drop {
            pre {
                NiftyHorns.drops[dropID] != nil: "Cannot borrow Drop: The Drop doesn't exist"
            }
            
            // Get a reference to the Drop and return it
            // use `&` to indicate the reference to the object and type
            return &NiftyHorns.drops[dropID] as &Drop
        }

        // startNewSeries ends the current series by incrementing
        // the series number, meaning that Cards minted after this
        // will use the new series number
        //
        // Returns: The new series number
        //
        pub fun startNewSeries(): UInt32 {
            // End the current series and start a new one
            // by incrementing the NiftyHorns series number
            NiftyHorns.currentSeries = NiftyHorns.currentSeries + UInt32(1)

            emit NewSeriesStarted(newCurrentSeries: NiftyHorns.currentSeries)

            return NiftyHorns.currentSeries
        }

        // createNewAdmin creates a new Admin resource
        //
        pub fun createNewAdmin(): @Admin {
            return <-create Admin()
        }
    }

    // This is the interface that users can cast their Card Collection as
    // to allow others to deposit Cards into their Collection. It also allows for reading
    // the IDs of Cards in the Collection.
    pub resource interface CardCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun batchDeposit(tokens: @NonFungibleToken.Collection)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowCard(id: UInt64): &NiftyHorns.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id): 
                    "Cannot borrow Card reference: The ID of the returned reference is incorrect"
            }
        }
    }

    // Collection is a resource that every user who owns NFTs 
    // will store in their account to manage their NFTs
    //
    pub resource Collection: CardCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic { 
        // Dictionary of Card conforming tokens
        // NFT is a resource type with a UInt64 ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init() {
            self.ownedNFTs <- {}
        }

        // withdraw removes an Card from the Collection and moves it to the caller
        //
        // Parameters: withdrawID: The ID of the NFT 
        // that is to be removed from the Collection
        //
        // returns: @NonFungibleToken.NFT the token that was withdrawn
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {

            // Remove the nft from the Collection
            let token <- self.ownedNFTs.remove(key: withdrawID) 
                ?? panic("Cannot withdraw: Card does not exist in the collection")

            emit Withdraw(id: token.id, from: self.owner?.address)
            
            // Return the withdrawn token
            return <-token
        }

        // batchWithdraw withdraws multiple tokens and returns them as a Collection
        //
        // Parameters: ids: An array of IDs to withdraw
        //
        // Returns: @NonFungibleToken.Collection: A collection that contains
        //                                        the withdrawn cards
        //
        pub fun batchWithdraw(ids: [UInt64]): @NonFungibleToken.Collection {
            // Create a new empty Collection
            var batchCollection <- create Collection()
            
            // Iterate through the ids and withdraw them from the Collection
            for id in ids {
                batchCollection.deposit(token: <-self.withdraw(withdrawID: id))
            }
            
            // Return the withdrawn tokens
            return <-batchCollection
        }

        // deposit takes a Card and adds it to the Collections dictionary
        //
        // Paramters: token: the NFT to be deposited in the collection
        //
        pub fun deposit(token: @NonFungibleToken.NFT) {
            
            // Cast the deposited token as a NiftyHorns NFT to make sure
            // it is the correct type
            let token <- token as! @NiftyHorns.NFT

            // Get the token's ID
            let id = token.id

            // Add the new token to the dictionary
            let oldToken <- self.ownedNFTs[id] <- token

            // Only emit a deposit event if the Collection 
            // is in an account's storage
            if self.owner?.address != nil {
                emit Deposit(id: id, to: self.owner?.address)
            }

            // Destroy the empty old token that was "removed"
            destroy oldToken
        }

        // batchDeposit takes a Collection object as an argument
        // and deposits each contained NFT into this Collection
        pub fun batchDeposit(tokens: @NonFungibleToken.Collection) {

            // Get an array of the IDs to be deposited
            let keys = tokens.getIDs()

            // Iterate through the keys in the collection and deposit each one
            for key in keys {
                self.deposit(token: <-tokens.withdraw(withdrawID: key))
            }

            // Destroy the empty Collection
            destroy tokens
        }

        // getIDs returns an array of the IDs that are in the Collection
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT Returns a borrowed reference to a Card in the Collection
        // so that the caller can read its ID
        //
        // Parameters: id: The ID of the NFT to get the reference for
        //
        // Returns: A reference to the NFT
        //
        // Note: This only allows the caller to read the ID of the NFT,
        // not any topshot specific data. Please use borrowCard to 
        // read Card data.
        //
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        // borrowCard returns a borrowed reference to a Card
        // so that the caller can read data and call methods from it.
        // They can use this to read its dropID, cardTypeID, serialNumber,
        // or any of the dropData or CardType data associated with it by
        // getting the dropID or cardTypeID and reading those fields from
        // the smart contract.
        //
        // Parameters: id: The ID of the NFT to get the reference for
        //
        // Returns: A reference to the NFT
        pub fun borrowCard(id: UInt64): &NiftyHorns.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &NiftyHorns.NFT
            } else {
                return nil
            }
        }

        // If a transaction destroys the Collection object,
        // All the NFTs contained within are also destroyed!
        //
        destroy() {
            destroy self.ownedNFTs
        }
    }

    // -----------------------------------------------------------------------
    // Nifty Horns contract-level function definitions
    // -----------------------------------------------------------------------

    // createEmptyCollection creates a new, empty Collection object so that
    // a user can store it in their account storage.
    // Once they have a Collection in their storage, they are able to receive
    // Cards in transactions.
    //
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <-create NiftyHorns.Collection()
    }

    // getAllCardTypes returns all the cardTypes in topshot
    //
    // Returns: An array of all the cardTypes that have been created
    pub fun getAllCardTypes(): [NiftyHorns.CardType] {
        return NiftyHorns.cardTypeDatas.values
    }

    // getCardTypeMetaData returns all the metadata associated with a specific CardType
    // 
    // Parameters: cardTypeID: The id of the CardType that is being searched
    //
    // Returns: The metadata as a String to String mapping optional
    pub fun getCardTypeMetaData(cardTypeID: UInt32): {String: String}? {
        return self.cardTypeDatas[cardTypeID]?.metadata
    }

    // getCardTypeMetaDataByField returns the metadata associated with a 
    //                        specific field of the metadata
    //                        Ex: field: "Player Name" will return something
    //                        like "John Smith"
    // 
    // Parameters: cardTypeID: The id of the CardType that is being searched
    //             field: The field to search for
    //
    // Returns: The metadata field as a String Optional
    pub fun getCardTypeMetaDataByField(cardTypeID: UInt32, field: String): String? {
        // Don't force a revert if the cardTypeID or field is invalid
        if let cardType = NiftyHorns.cardTypeDatas[cardTypeID] {
            return cardType.metadata[field]
        } else {
            return nil
        }
    }

    // getDropName returns the name that the specified Drop
    //            is associated with.
    // 
    // Parameters: dropID: The id of the Drop that is being searched
    //
    // Returns: The name of the Drop
    pub fun getDropName(dropID: UInt32): String? {
        // Don't force a revert if the dropID is invalid
        return NiftyHorns.dropDatas[dropID]?.name
    }

    // getDropSeries returns the series that the specified Drop
    //              is associated with.
    // 
    // Parameters: dropID: The id of the Drop that is being searched
    //
    // Returns: The series that the Drop belongs to
    pub fun getDropSeries(dropID: UInt32): UInt32? {
        // Don't force a revert if the dropID is invalid
        return NiftyHorns.dropDatas[dropID]?.series
    }

    // getDropIDsByName returns the IDs that the specified Drop name
    //                 is associated with.
    // 
    // Parameters: dropName: The name of the Drop that is being searched
    //
    // Returns: An array of the IDs of the Drop if it exists, or nil if doesn't
    pub fun getDropIDsByName(dropName: String): [UInt32]? {
        var dropIDs: [UInt32] = []

        // Iterate through all the dropDatas and search for the name
        for dropData in NiftyHorns.dropDatas.values {
            if dropName == dropData.name {
                // If the name is found, return the ID
                dropIDs.append(dropData.dropID)
            }
        }

        // If the name isn't found, return nil
        // Don't force a revert if the dropName is invalid
        if dropIDs.length == 0 {
            return nil
        } else {
            return dropIDs
        }
    }

    // getCardTypesInDrop returns the list of CardType IDs that are in the Drop
    // 
    // Parameters: dropID: The id of the Drop that is being searched
    //
    // Returns: An array of CardType IDs
    pub fun getCardTypesInDrop(dropID: UInt32): [UInt32]? {
        // Don't force a revert if the dropID is invalid
        return NiftyHorns.drops[dropID]?.cardTypes
    }

    // isEditionRetired returns a boolean that indicates if a Drop/CardType combo
    //                  (otherwise known as an edition) is retired.
    //                  If an edition is retired, it still remains in the Drop,
    //                  but Cards can no longer be minted from it.
    // 
    // Parameters: dropID: The id of the Drop that is being searched
    //             cardTypeID: The id of the CardType that is being searched
    //
    // Returns: Boolean indicating if the edition is retired or not
    pub fun isEditionRetired(dropID: UInt32, cardTypeID: UInt32): Bool? {
        // Don't force a revert if the drop or cardType ID is invalid
        // Remove the drop from the dictionary to get its field
        if let dropToRead <- NiftyHorns.drops.remove(key: dropID) {

            // See if the CardType is retired from this Drop
            let retired = dropToRead.retired[cardTypeID]

            // Put the Drop back in the contract storage
            NiftyHorns.drops[dropID] <-! dropToRead

            // Return the retired status
            return retired
        } else {

            // If the Drop wasn't found, return nil
            return nil
        }
    }

    // isDropLocked returns a boolean that indicates if a Drop
    //             is locked. If it's locked, 
    //             new CardTypes can no longer be added to it,
    //             but Cards can still be minted from CardTypes the drop contains.
    // 
    // Parameters: dropID: The id of the Drop that is being searched
    //
    // Returns: Boolean indicating if the Drop is locked or not
    pub fun isDropLocked(dropID: UInt32): Bool? {
        // Don't force a revert if the dropID is invalid
        return NiftyHorns.drops[dropID]?.locked
    }

    // getNumCardsInEdition return the number of Cards that have been 
    //                        minted from a certain edition.
    //
    // Parameters: dropID: The id of the Drop that is being searched
    //             cardTypeID: The id of the CardType that is being searched
    //
    // Returns: The total number of Cards 
    //          that have been minted from an edition
    pub fun getNumCardsInEdition(dropID: UInt32, cardTypeID: UInt32): UInt32? {
        // Don't force a revert if the Drop or cardType ID is invalid
        // Remove the Drop from the dictionary to get its field
        if let dropToRead <- NiftyHorns.drops.remove(key: dropID) {

            // Read the numMintedPerCardType
            let amount = dropToRead.numberMintedPerCardType[cardTypeID]

            // Put the Drop back into the Drops dictionary
            NiftyHorns.drops[dropID] <-! dropToRead

            return amount
        } else {
            // If the drop wasn't found return nil
            return nil
        }
    }

    // -----------------------------------------------------------------------
    // Nifty Horns initialization function
    // -----------------------------------------------------------------------
    //
    init() {
        // Initialize contract fields
        self.currentSeries = 0
        self.cardTypeDatas = {}
        self.dropDatas = {}
        self.drops <- {}
        self.nextCardTypeID = 1
        self.nextDropID = 1
        self.totalSupply = 0

        // Put a new Collection in storage
        self.account.save<@Collection>(<- create Collection(), to: /storage/CardCollection)

        // Create a public capability for the Collection
        self.account.link<&{CardCollectionPublic}>(/public/CardCollection, target: /storage/CardCollection)

        // Put the Minter in storage
        self.account.save<@Admin>(<- create Admin(), to: /storage/NiftyHornsAdmin)

        emit ContractInitialized()
    }
}
 
