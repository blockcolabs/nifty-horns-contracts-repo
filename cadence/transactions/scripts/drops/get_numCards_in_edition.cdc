import NiftyHorns from 0xNIFTYHORNSADDRESS

// This script returns the number of specified cards that have been
// minted for the specified edition

// Parameters:
//
// dropID: The unique ID for the drop whose data needs to be read
// cardTypeID: The unique ID for the cardType whose data needs to be read

// Returns: UInt32
// number of cards with specified cardTypeID minted for a drop with specified dropID

pub fun main(dropID: UInt32, cardTypeID: UInt32): UInt32 {

    let numCards = NiftyHorns.getNumCardsInEdition(dropID: dropID, cardTypeID: cardTypeID)
        ?? panic("Could not find the specified edition")

    return numCards
}