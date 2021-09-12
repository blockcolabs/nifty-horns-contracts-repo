import NiftyHorns from 0xNIFTYHORNSADDRESS
import NiftyHornsMarket from 0xMARKETADDRESS

// This transaction is for a user to stop a card sale in their account

// Parameters
//
// tokenID: the ID of the card whose sale is to be delisted

transaction(tokenID: UInt64) {

    prepare(acct: AuthAccount) {

        // borrow a reference to the owner's sale collection
        if let niftyHornsSaleCollection = acct.borrow<&NiftyHornsMarket.SaleCollection>(from: NiftyHornsMarket.marketStoragePath) {

            // cancel the card from the sale, thereby de-listing it
            niftyHornsSaleCollection.cancelSale(tokenID: tokenID)

        } else if let niftyHornsSaleCollection = acct.borrow<&Market.SaleCollection>(from: /storage/niftyHornsSaleCollection) {
            // Borrow a reference to the NFT collection in the signers account
            let collectionRef = acct.borrow<&NiftyHorns.Collection>(from: /storage/CardCollection)
                ?? panic("Could not borrow from CardCollection in storage")

            // withdraw the card from the sale, thereby de-listing it
            let token <- niftyHornsSaleCollection.withdraw(tokenID: tokenID)

            // deposit the card into the owner's collection
            collectionRef.deposit(token: <-token)
        }
    }
}