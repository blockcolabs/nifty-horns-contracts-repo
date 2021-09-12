import NiftyHornsMarket from 0xMARKETADDRESS

pub fun main(sellerAddress: Address, cardID: UInt64): UInt32 {
    let saleRef = getAccount(sellerAddress).getCapability(NiftyHornsMarket.marketPublicPath)
        .borrow<&{Market.SaleCollection}>()
        ?? panic("Could not get public sale reference")

    let token = saleRef.borrowCard(id: cardID)
        ?? panic("Could not borrow a reference to the specified card")

    let data = token.data

    return data.dropID
}