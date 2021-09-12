import FungibleToken from 0xFUNGIBLETOKENADDRESS
import NiftyHorns from 0xNIFTYHORNSADDRESS
import NiftyHornsMarket from 0xMARKETADDRESS

// This transaction is for a user to purchase a card that another user
// has for sale in their sale collection

// Parameters
//
// sellerAddress: the Flow address of the account issuing the sale of a card
// tokenID: the ID of the card being purchased
// purchaseAmount: the amount for which the user is paying for the card; must not be less than the card's price

transaction(sellerAddress: Address, tokenID: UInt64, purchaseAmount: UFix64) {
    prepare(acct: AuthAccount) {

        // borrow a reference to the signer's collection
        let collection = acct.borrow<&NiftyHorns.Collection>(from: /storage/CardCollection)
            ?? panic("Could not borrow reference to the Card Collection")

        // borrow a reference to the signer's fungible token Vault
        let provider = acct.borrow<&DapperUtilityCoin.Vault{FungibleToken.Provider}>(from: /storage/dapperUtilityCoinVault)!

        // withdraw tokens from the signer's vault
        let tokens <- provider.withdraw(amount: purchaseAmount) as! @DapperUtilityCoin.Vault

        // get the seller's public account object
        let seller = getAccount(sellerAddress)

        // borrow a public reference to the seller's sale collection
        let niftyHornsSaleCollection = seller.getCapability(NiftyHornsMarket.marketPublicPath)
            .borrow<&{Market.SaleCollection}>()
            ?? panic("Could not borrow public sale reference")

        // purchase the card
        let purchasedToken <- niftyHornsSaleCollection.purchase(tokenID: tokenID, buyTokens: <-tokens)

        // deposit the purchased card into the signer's collection
        collection.deposit(token: <-purchasedToken)
    }
}