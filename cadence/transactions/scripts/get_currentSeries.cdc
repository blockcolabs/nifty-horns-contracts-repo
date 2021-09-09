import NiftyHorns from 0xNIFTYHORNSADDRESS

// This script reads the current series from the NiftyHorns contract and
// returns that number to the caller

// Returns: UInt32
// currentSeries field in NiftyHorns contract

pub fun main(): UInt32 {

    return NiftyHorns.currentSeries
}