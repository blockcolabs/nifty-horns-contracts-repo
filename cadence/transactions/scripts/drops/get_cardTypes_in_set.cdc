import NiftyHorns from 0xNIFTYHORNSADDRESS

// This script returns an array of the cardType IDs that are
// in the specified drop

// Parameters:
//
// dropID: The unique ID for the drop whose data needs to be read

// Returns: [UInt32]
// Array of cardType IDs in specified drop

pub fun main(dropID: UInt32): [UInt32] {

    let cardTypes = NiftyHorns.getCardTypesInDrop(dropID: dropID)!

    return cardTypes
}