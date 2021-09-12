import FungibleToken from 0xFUNGIBLETOKENADDRESS
import NiftyHorns from 0xNIFTYHORNSADDRESS
import NiftyHornsMarket from 0xMARKETADDRESS

// This transaction purchases a card from the sale collection

transaction(seller: Address, recipient: Address, cardID: UInt64, purchaseAmount: UFix64) {

    let purchaseTokens: @DapperUtilityCoin.Vault

    prepare(acct: AuthAccount) {

        // Borrow a provider reference to the buyers vault
        let provider = acct.borrow<&DapperUtilityCoin.Vault{FungibleToken.Provider}>(from: /storage/dapperUtilityCoinVault)
            ?? panic("Could not borrow a reference to the buyers FlowToken Vault")

        // withdraw the purchase tokens from the vault
        self.purchaseTokens <- provider.withdraw(amount: purchaseAmount) as! @DapperUtilityCoin.Vault

    }

    execute {

        // get the accounts for the seller and recipient
        let seller = getAccount(seller)
        let recipient = getAccount(recipient)

        // Get the reference for the recipient's nft receiver
        let receiverRef = recipient.getCapability(/public/CardCollection)!.borrow<&{NiftyHorns.CardCollectionPublic}>()
            ?? panic("Could not borrow a reference to the recipients card collection")

        if let marketCollectionRef = seller.getCapability(/public/niftyHornsSalev3Collection)
                .borrow<&{Market.SaleCollection}>() {

            let purchasedToken <- marketCollectionRef.purchase(tokenID: cardID, buyTokens: <-self.purchaseTokens)
            receiverRef.deposit(token: <-purchasedToken)

        } else {
            panic("Could not borrow reference to either Sale collection")
        }
    }
}