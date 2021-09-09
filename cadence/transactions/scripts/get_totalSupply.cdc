import NiftyHorns from 0xNIFTYHORNSADDRESS

// This script reads the current number of cards that have been minted
// from the NiftyHorns contract and returns that number to the caller

// Returns: UInt64
// Number of cards minted from NiftyHorns contract

pub fun main(): UInt64 {

    return NiftyHorns.totalSupply
}