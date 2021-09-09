import NiftyHorns from 0xNIFTYHORNSADDRESS

// This script returns an array of all the cardTypes
// that have ever been created for Nifty Horns

// Returns: [NiftyHorns.CardType]
// array of all cardTypes created for Nifty Horns

pub fun main(): [NiftyHorns.CardType] {

    return NiftyHorns.getAllCardTypes()
}