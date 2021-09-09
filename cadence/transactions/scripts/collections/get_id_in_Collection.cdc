import NiftyHorns from 0xNIFTYHORNSADDRESS

// This script returns true if a card with the specified ID
// exists in a user's collection

// Parameters:
//
// account: The Flow Address of the account whose card data needs to be read
// id: The unique ID for the card whose data needs to be read

// Returns: Bool
// Whether a card with specified ID exists in user's collection

pub fun main(account: Address, id: UInt64): Bool {

    let collectionRef = getAccount(account).getCapability(/public/CardCollection)
        .borrow<&{NiftyHorns.CardCollectionPublic}>()
        ?? panic("Could not get public card collection reference")

    return collectionRef.borrowNFT(id: id) != nil
}