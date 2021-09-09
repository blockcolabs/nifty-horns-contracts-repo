import NiftyHorns from 0xNIFTYHORNSADDRESS

// This script gets the metadata associated with a card
// in a collection by looking up its cardTypeID and then searching
// for that cardType's metadata in the NiftyHorns contract

// Parameters:
//
// account: The Flow Address of the account whose card data needs to be read
// id: The unique ID for the card whose data needs to be read

// Returns: {String: String}
// A dictionary of all the cardType metadata associated
// with the specified card

pub fun main(account: Address, id: UInt64): {String: String} {

    // get the public capability for the owner's card collection
    // and borrow a reference to it
    let collectionRef = getAccount(account).getCapability(/public/CardCollection)
        .borrow<&{NiftyHorns.CardCollectionPublic}>()
        ?? panic("Could not get public card collection reference")

    // Borrow a reference to the specified card
    let token = collectionRef.borrowCard(id: id)
        ?? panic("Could not borrow a reference to the specified card")

    // Get the card's metadata to access its cardType and Drop IDs
    let data = token.data

    // Use the card's cardType ID
    // to get all the metadata associated with that cardType
    let metadata = NiftyHorns.getCardTypeMetaData(cardTypeID: data.cardTypeID) ?? panic("CardType doesn't exist")

    log(metadata)

    return metadata
}