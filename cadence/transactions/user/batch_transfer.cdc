import NonFungibleToken from 0xNFTADDRESS
import NiftyHorns from 0xNIFTYHORNSADDRESS

// This transaction transfers a number of cards to a recipient

// Parameters
//
// recipientAddress: the Flow address who will receive the NFTs
// cardIDs: an array of card IDs of NFTs that recipient will receive

transaction(recipientAddress: Address, cardIDs: [UInt64]) {

    let transferTokens: @NonFungibleToken.Collection

    prepare(acct: AuthAccount) {

        self.transferTokens <- acct.borrow<&NiftyHorns.Collection>(from: /storage/CardCollection)!.batchWithdraw(ids: cardIDs)
    }

    execute {

        // get the recipient's public account object
        let recipient = getAccount(recipientAddress)

        // get the Collection reference for the receiver
        let receiverRef = recipient.getCapability(/public/CardCollection).borrow<&{NiftyHorns.CardCollectionPublic}>()
            ?? panic("Could not borrow a reference to the recipients card receiver")

        // deposit the NFT in the receivers collection
        receiverRef.batchDeposit(tokens: <-self.transferTokens)
    }
}