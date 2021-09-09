import NiftyHorns from 0xNIFTYHORNSADDRESS

// This transaction is what an admin would use to mint a single new card
// and deposit it in a user's collection

// Parameters:
//
// dropID: the ID of a drop containing the target cardType
// cardTypeID: the ID of a cardType from which a new card is minted
// recipientAddr: the Flow address of the account receiving the newly minted card

transaction(dropID: UInt32, cardTypeID: UInt32, recipientAddr: Address) {
    // local variable for the admin reference
    let adminRef: &NiftyHorns.Admin

    prepare(acct: AuthAccount) {
        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&NiftyHorns.Admin>(from: /storage/NiftyHornsAdmin)!
    }

    execute {
        // Borrow a reference to the specified drop
        let dropRef = self.adminRef.borrowDrop(dropID: dropID)

        // Mint a new NFT
        let card1 <- dropRef.mintCard(cardTypeID: cardTypeID)

        // get the public account object for the recipient
        let recipient = getAccount(recipientAddr)

        // get the Collection reference for the receiver
        let receiverRef = recipient.getCapability(/public/CardCollection).borrow<&{NiftyHorns.CardCollectionPublic}>()
            ?? panic("Cannot borrow a reference to the recipient's card collection")

        // deposit the NFT in the receivers collection
        receiverRef.deposit(token: <-card1)
    }
}