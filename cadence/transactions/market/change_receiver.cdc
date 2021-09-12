import NiftyHornsMarket from 0xMARKETADDRESS

transaction(receiverPath: PublicPath) {
    prepare(acct: AuthAccount) {

        let niftyHornsSaleCollection = acct.borrow<&NiftyHornsMarket.SaleCollection>(from: /storage/niftyHornsSaleCollection)
            ?? panic("Could not borrow from sale in storage")

        niftyHornsSaleCollection.changeOwnerReceiver(acct.getCapability(receiverPath))
    }
}