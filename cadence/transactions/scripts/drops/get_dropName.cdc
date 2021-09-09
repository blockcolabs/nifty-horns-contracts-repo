import NiftyHorns from 0xNIFTYHORNSADDRESS

// This script gets the dropName of a drop with specified dropID

// Parameters:
//
// dropID: The unique ID for the drop whose data needs to be read

// Returns: String
// Name of drop with specified dropID

pub fun main(dropID: UInt32): String {

    let name = NiftyHorns.getDropName(dropID: dropID)
        ?? panic("Could not find the specified drop")

    return name
}