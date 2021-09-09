import NiftyHorns from 0xNIFTYHORNSADDRESS

// This script reads the public nextCardTypeID from the NiftyHorns contract and
// returns that number to the caller

// Returns: UInt32
// the nextCardTypeID field in NiftyHorns contract

pub fun main(): UInt32 {

    log(NiftyHorns.nextCardTypeID)

    return NiftyHorns.nextCardTypeID
}