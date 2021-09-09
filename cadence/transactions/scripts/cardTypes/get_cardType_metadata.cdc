import NiftyHorns from 0xNIFTYHORNSADDRESS

// This script returns the full metadata associated with a cardType
// in the NiftyHorns smart contract

// Parameters:
//
// cardTypeID: The unique ID for the cardType whose data needs to be read

// Returns: {String:String}
// A dictionary of all the cardType metadata associated
// with the specified cardTypeID

pub fun main(cardTypeID: UInt32): {String:String} {

    let metadata = NiftyHorns.getCardTypeMetaData(cardTypeID: cardTypeID) ?? panic("CardType doesn't exist")

    log(metadata)

    return metadata
}