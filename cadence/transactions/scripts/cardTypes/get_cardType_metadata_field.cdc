import NiftyHorns from 0xNIFTYHORNSADDRESS

// This script returns the value for the specified metadata field
// associated with a cardType in the NiftyHorns smart contract

// Parameters:
//
// cardTypeID: The unique ID for the cardType whose data needs to be read
// field: The specified metadata field whose data needs to be read

// Returns: String
// Value of specified metadata field associated with specified cardTypeID

pub fun main(cardTypeID: UInt32, field: String): String {

    let field = NiftyHorns.getCardTypeMetaDataByField(cardTypeID: cardTypeID, field: field) ?? panic("CardType doesn't exist")

    log(field)

    return field
}