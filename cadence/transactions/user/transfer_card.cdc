import NonFungibleToken from 0xNFTADDRESS
import NiftyHorns from 0xNIFTYHORNSADDRESS

// This transaction transfers a card to a recipient

// This transaction is how a Nifty Horns user would transfer a card
// from their account to another account
// The recipient must have a NiftyHorns Collection object stored
// and a public CardCollectionPublic capability stored at
// `/public/CardCollection`

// Parameters:
//
// recipient: The Flow address of the account to receive the card.
// withdrawID: The id of the card to be transferred

transaction(recipient: Address, withdrawID: UInt64) {

    // local variable for storing the transferred token
    let transferToken: @NonFungibleToken.NFT

    prepare(acct: AuthAccount) {

        // borrow a reference to the owner's collection
        let collectionRef = acct.borrow<&NiftyHorns.Collection>(from: /storage/CardCollection)
            ?? panic("Could not borrow a reference to the stored Card collection")

        // withdraw the NFT
        self.transferToken <- collectionRef.withdraw(withdrawID: withdrawID)
    }

    execute {

        // get the recipient's public account object
        let recipient = getAccount(recipient)

        // get the Collection reference for the receiver
        let receiverRef = recipient.getCapability(/public/CardCollection).borrow<&{NiftyHorns.CardCollectionPublic}>()!

        // deposit the NFT in the receivers collection
        receiverRef.deposit(token: <-self.transferToken)
    }
}