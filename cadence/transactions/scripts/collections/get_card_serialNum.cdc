import NiftyHorns from 0xNIFTYHORNSADDRESS

// This script gets the serial number of a card
// by borrowing a reference to the card
// and returning its serial number

// Parameters:
//
// account: The Flow Address of the account whose card data needs to be read
// id: The unique ID for the card whose data needs to be read

// Returns: UInt32
// The serialNumber associated with a card with a specified ID

pub fun main(account: Address, id: UInt64): UInt32 {

    let collectionRef = getAccount(account).getCapability(/public/CardCollection)
        .borrow<&{NiftyHorns.CardCollectionPublic}>()
        ?? panic("Could not get public card collection reference")

    let token = collectionRef.borrowCard(id: id)
        ?? panic("Could not borrow a reference to the specified card")

    let data = token.data

    return data.serialNumber
}