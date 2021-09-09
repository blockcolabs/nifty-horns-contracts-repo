import NiftyHorns from 0xNIFTYHORNSADDRESS

// This transaction mints multiple cards
// from a single drop/cardType combination (otherwise known as edition)

// Parameters:
//
// dropID: the ID of the drop to be minted from
// cardTypeID: the ID of the CardType from which the Cards are minted
// quantity: the quantity of Cards to be minted
// recipientAddr: the Flow address of the account receiving the collection of minted cards

transaction(dropID: UInt32, cardTypeID: UInt32, quantity: UInt64, recipientAddr: Address) {

    // Local variable for the Nifty Horns Admin object
    let adminRef: &NiftyHorns.Admin

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&NiftyHorns.Admin>(from: /storage/NiftyHornsAdmin)!
    }

    execute {

        // borrow a reference to the drop to be minted from
        let dropRef = self.adminRef.borrowDrop(dropID: dropID)

        // Mint all the new NFTs
        let collection <- dropRef.batchMintCard(cardTypeID: cardTypeID, quantity: quantity)

        // Get the account object for the recipient of the minted tokens
        let recipient = getAccount(recipientAddr)

        // get the Collection reference for the receiver
        let receiverRef = recipient.getCapability(/public/CardCollection).borrow<&{NiftyHorns.CardCollectionPublic}>()
            ?? panic("Cannot borrow a reference to the recipient's collection")

        // deposit the NFT in the receivers collection
        receiverRef.batchDeposit(tokens: <-collection)
    }
}