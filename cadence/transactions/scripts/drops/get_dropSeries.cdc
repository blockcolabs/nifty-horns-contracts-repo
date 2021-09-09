import NiftyHorns from 0xNIFTYHORNSADDRESS

// This script reads the series of the specified drop and returns it

// Parameters:
//
// dropID: The unique ID for the drop whose data needs to be read

// Returns: UInt32
// unique ID of series

pub fun main(dropID: UInt32): UInt32 {

    let series = NiftyHorns.getDropSeries(dropID: dropID)
        ?? panic("Could not find the specified drop")

    return series
}