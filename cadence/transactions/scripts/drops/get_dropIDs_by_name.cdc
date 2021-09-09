import NiftyHorns from 0xNIFTYHORNSADDRESS

// This script returns an array of the dropIDs
// that have the specified name

// Parameters:
//
// dropName: The name of the drop whose data needs to be read

// Returns: [UInt32]
// Array of dropIDs that have specified drop name

pub fun main(dropName: String): [UInt32] {

    let ids = NiftyHorns.getDropIDsByName(dropName: dropName)
        ?? panic("Could not find the specified drop name")

    return ids
}