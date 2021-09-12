import NiftyHorns from 0xNIFTYHORNSADDRESS
import NiftyHornsMarket from 0xMARKETADDRESS

// This transaction changes the price of a card that a user has for sale

// Parameters:
//
// tokenID: the ID of the card whose price is being changed
// newPrice: the new price of the card

transaction(tokenID: UInt64, newPrice: UFix64) {
    prepare(acct: AuthAccount) {

        // borrow a reference to the owner's sale collection
        let niftyHornsSaleCollection = acct.borrow<&NiftyHornsMarket.SaleCollection>(from: NiftyHornsMarket.marketStoragePath)
            ?? panic("Could not borrow from sale in storage")

        // Change the price of the card
        niftyHornsSaleCollection.listForSale(tokenID: tokenID, price: newPrice)
    }
}