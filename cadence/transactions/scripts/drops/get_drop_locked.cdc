import NiftyHorns from 0xNIFTYHORNSADDRESS

// This script returns a boolean indicating if the specified drop is locked
// meaning new cardTypes cannot be added to it

// Parameters:
//
// dropID: The unique ID for the drop whose data needs to be read

// Returns: Bool
// Whether specified drop is locked

pub fun main(dropID: UInt32): Bool {

    let isLocked = NiftyHorns.isDropLocked(dropID: dropID)
        ?? panic("Could not find the specified drop")

    return isLocked
}