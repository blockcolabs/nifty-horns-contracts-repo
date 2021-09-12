import NonFungibleToken from 0xNFTADDRESS
import NiftyHorns from 0xNIFTYHORNSADDRESS

// This transaction is what Nifty Horns uses to send the cards in a "pack" to
// a user's collection

// Parameters:
//
// recipientAddr: the Flow address of the account receiving a pack of cards
// cardsIDs: an array of card IDs to be withdrawn from the owner's card collection

transaction(recipientAddr: Address, cardIDs: [UInt64]) {

    prepare(acct: AuthAccount) {

        // get the recipient's public account object
        let recipient = getAccount(recipientAddr)

        // borrow a reference to the recipient's card collection
        let receiverRef = recipient.getCapability(/public/CardCollection)
            .borrow<&{NiftyHorns.CardCollectionPublic}>()
            ?? panic("Could not borrow reference to receiver's collection")

        // borrow a reference to the owner's card collection
        let collection = acct.borrow<&NiftyHorns.Collection>(from: /storage/CardCollection)!

        // Deposit the pack of cards to the recipient's collection
        receiverRef.batchDeposit(tokens: <-collection.batchWithdraw(ids: cardIDs))

    }
}