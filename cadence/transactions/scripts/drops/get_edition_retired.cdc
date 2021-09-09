import NiftyHorns from 0xNIFTYHORNSADDRESS

// This transaction reads if a specified edition is retired

// Parameters:
//
// dropID: The unique ID for the drop whose data needs to be read
// cardTypeID: The unique ID for the cardType whose data needs to be read

// Returns: Bool
// Whether specified drop is retired

pub fun main(dropID: UInt32, cardTypeID: UInt32): Bool {

    let isRetired = NiftyHorns.isEditionRetired(dropID: dropID, cardTypeID: cardTypeID)
        ?? panic("Could not find the specified edition")

    return isRetired
}