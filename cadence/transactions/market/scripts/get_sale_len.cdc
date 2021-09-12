import NiftyHornsMarket from 0xMARKETADDRESS

pub fun main(sellerAddress: Address): Int {
    let acct = getAccount(sellerAddress)
    let collectionRef = acct.getCapability(NiftyHornsMarket.marketPublicPath)
        .borrow<&{Market.SaleCollection}>()
        ?? panic("Could not borrow capability from public collection")

    return collectionRef.getIDs().length
}