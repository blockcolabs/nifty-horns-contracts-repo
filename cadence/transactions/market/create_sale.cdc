import FungibleToken from 0xFUNGIBLETOKENADDRESS
import NiftyHorns from 0xNIFTYHORNSADDRESS
import NiftyHornsMarket from 0xMARKETADDRESS

// This transaction creates a sale collection and stores it in the signer's account
// It does not put an NFT up for sale

// Parameters
//
// beneficiaryAccount: the Flow address of the account where a cut of the purchase will be sent
// cutPercentage: how much in percentage the beneficiary will receive from the sale

transaction(tokenReceiverPath: PublicPath, beneficiaryAccount: Address, cutPercentage: UFix64) {
    prepare(acct: AuthAccount) {
        let ownerCapability = acct.getCapability<&AnyResource{FungibleToken.Receiver}>(tokenReceiverPath)

        let beneficiaryCapability = getAccount(beneficiaryAccount).getCapability<&AnyResource{FungibleToken.Receiver}>(tokenReceiverPath)

        let ownerCollection = acct.link<&NiftyHorns.Collection>(/private/CardCollection, target: /storage/CardCollection)!

        let collection <- NiftyHornsMarket.createSaleCollection(ownerCollection: ownerCollection,
                                                               ownerCapability: ownerCapability,
                                                               beneficiaryCapability: beneficiaryCapability,
                                                               cutPercentage: cutPercentage)

        acct.save(<-collection, to: NiftyHornsMarket.marketStoragePath)

        acct.link<&NiftyHornsMarket.SaleCollection{Market.SaleCollection}>(NiftyHornsMarket.marketPublicPath, target: NiftyHornsMarket.marketStoragePath)
    }
}
