import FungibleToken from 0xFUNGIBLETOKENADDRESS
import NiftyHorns from 0xNIFTYHORNSADDRESS
import NiftyHornsMarket from 0xMARKETADDRESS

transaction(sellerAddress: Address, recipient: Address, tokenID: UInt64, purchaseAmount: UFix64) {

    prepare(signer: AuthAccount) {

        let tokenAdmin = signer
            .borrow<&DapperUtilityCoin.Administrator>(from: /storage/dapperUtilityCoinAdmin) 
            ?? panic("Signer is not the token admin")

        let minter <- tokenAdmin.createNewMinter(allowedAmount: purchaseAmount)
        let mintedVault <- minter.mintTokens(amount: purchaseAmount) as! @DapperUtilityCoin.Vault

        destroy minter

        let seller = getAccount(sellerAddress)
        let niftyHornsSaleCollection = seller.getCapability(NiftyHornsMarket.marketPublicPath)
            .borrow<&{Market.SaleCollection}>()
            ?? panic("Could not borrow public sale reference")

        let boughtToken <- niftyHornsSaleCollection.purchase(tokenID: tokenID, buyTokens: <-mintedVault)

        // get the recipient's public account object and borrow a reference to their card receiver
        let recipient = getAccount(recipient)
            .getCapability(/public/CardCollection).borrow<&{NiftyHorns.CardCollectionPublic}>()
            ?? panic("Could not borrow a reference to the card collection")

        // deposit the NFT in the receivers collection
        recipient.deposit(token: <-boughtToken)
    }
}
