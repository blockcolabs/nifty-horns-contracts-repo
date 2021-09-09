import NiftyHorns from 0xNIFTYHORNSADDRESS

// This is the script to get a list of all the cards' ids an account owns
// Just change the argument to `getAccount` to whatever account you want
// and as long as they have a published Collection receiver, you can see
// the cards they own.

// Parameters:
//
// account: The Flow Address of the account whose card data needs to be read

// Returns: [UInt64]
// list of all cards' ids an account owns

pub fun main(account: Address): [UInt64] {

    let acct = getAccount(account)

    let collectionRef = acct.getCapability(/public/CardCollection)
                            .borrow<&{NiftyHorns.CardCollectionPublic}>()!

    log(collectionRef.getIDs())

    return collectionRef.getIDs()
}