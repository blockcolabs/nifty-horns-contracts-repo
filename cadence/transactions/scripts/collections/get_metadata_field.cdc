import NiftyHorns from 0xNIFTYHORNSADDRESS

// This script gets the metadata associated with a card
// in a collection by looking up its cardTypeID and then searching
// for that cardType's metadata in the NiftyHorns contract. It returns
// the value for the specified metadata field

// Parameters:
//
// account: The Flow Address of the account whose card data needs to be read
// cardID: The unique ID for the card whose data needs to be read
// fieldToSearch: The specified metadata field whose data needs to be read

// Returns: String
// Value of specified metadata field

pub fun main(account: Address, cardID: UInt64, fieldToSearch: String): String {

    // borrow a public reference to the owner's card collection
    let collectionRef = getAccount(account).getCapability(/public/CardCollection)
        .borrow<&{NiftyHorns.CardCollectionPublic}>()
        ?? panic("Could not get public card collection reference")

    // borrow a reference to the specified card in the collection
    let token = collectionRef.borrowCard(id: id)
        ?? panic("Could not borrow a reference to the specified card")

    // Get the tokens data
    let data = token.data

    // Get the metadata field associated with the specific cardType
    let field = NiftyHorns.getCardTypeMetaDataByField(cardTypeID: data.cardTypeID, field: fieldToSearch) ?? panic("CardType doesn't exist")

    log(field)

    return field
}