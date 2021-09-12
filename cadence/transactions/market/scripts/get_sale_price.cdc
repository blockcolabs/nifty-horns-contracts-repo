import NiftyHornsMarket from 0xMARKETADDRESS

pub fun main(sellerAddress: Address, cardID: UInt64): UFix64 {

    let acct = getAccount(sellerAddress)
    let collectionRef = acct.getCapability(NiftyHornsMarket.marketPublicPath).borrow<&{Market.SaleCollection}>()
        ?? panic("Could not borrow capability from public collection")

    let price = collectionRef.getPrice(tokenID: UInt64(cardID))
        ?? panic("Could not find price")

    return price

}