import NiftyHorns from 0xNIFTYHORNSADDRESS
import NiftyHornsMarket from 0xMARKETADDRESS

// This transaction is for a user to put a new card up for sale
// They must have NiftyHorns Collection and a NiftyHornsMarket Sale Collection already
// stored in their account

// Parameters
//
// cardId: the ID of the card to be listed for sale
// price: the sell price of the card

transaction(cardID: UInt64, price: UFix64) {
    prepare(acct: AuthAccount) {

        // borrow a reference to the Nifty Horns Sale Collection
        let niftyHornsSaleCollection = acct.borrow<&NiftyHornsMarket.SaleCollection>(from: NiftyHornsMarket.marketStoragePath)
            ?? panic("Could not borrow from sale in storage")

        // List the specified card for sale
        niftyHornsSaleCollection.listForSale(tokenID: cardID, price: price)
    }
}