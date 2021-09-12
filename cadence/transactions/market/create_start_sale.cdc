import FungibleToken from 0xFUNGIBLETOKENADDRESS
import NiftyHornsMarket from 0xMARKETADDRESS
import NiftyHorns from 0xNIFTYHORNSADDRESS

transaction(tokenReceiverPath: PublicPath, beneficiaryAccount: Address, cutPercentage: UFix64, cardID: UInt64, price: UFix64) {

    prepare(acct: AuthAccount) {
        // check to see if a sale collection already exists
        if acct.borrow<&NiftyHornsMarket.SaleCollection>(from: NiftyHornsMarket.marketStoragePath) == nil {
            // get the fungible token capabilities for the owner and beneficiary
            let ownerCapability = acct.getCapability<&{FungibleToken.Receiver}>(tokenReceiverPath)
            let beneficiaryCapability = getAccount(beneficiaryAccount).getCapability<&{FungibleToken.Receiver}>(tokenReceiverPath)

            let ownerCollection = acct.link<&NiftyHorns.Collection>(/private/CardCollection, target: /storage/CardCollection)!

            // create a new sale collection
            let niftyHornsSaleCollection <- NiftyHornsMarket.createSaleCollection(ownerCollection: ownerCollection,
                                                                             ownerCapability: ownerCapability,
                                                                             beneficiaryCapability: beneficiaryCapability,
                                                                             cutPercentage: cutPercentage)

            // save it to storage
            acct.save(<-niftyHornsSaleCollection, to: NiftyHornsMarket.marketStoragePath)

            // create a public link to the sale collection
            acct.link<&NiftyHornsMarket.SaleCollection{Market.SaleCollection}>(NiftyHornsMarket.marketPublicPath, target: NiftyHornsMarket.marketStoragePath)
        }

        // borrow a reference to the sale
        let niftyHornsSaleCollection = acct.borrow<&NiftyHornsMarket.SaleCollection>(from: NiftyHornsMarket.marketStoragePath)
            ?? panic("Could not borrow from sale in storage")

        // put the card up for sale
        niftyHornsSaleCollection.listForSale(tokenID: cardID, price: price)

    }
}