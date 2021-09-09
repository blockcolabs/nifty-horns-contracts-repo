import NiftyHorns from 0xNIFTYHORNSADDRESS

// This script reads the next Drop ID from the NiftyHorns contract and 
// returns that number to the caller

// Returns: UInt32
// Value of nextDropID field in NiftyHorns contract

pub fun main(): UInt32 {

    log(NiftyHorns.nextDropID)

    return NiftyHorns.nextDropID
}