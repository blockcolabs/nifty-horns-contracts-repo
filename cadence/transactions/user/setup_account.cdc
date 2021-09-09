import NiftyHorns from 0xNIFTYHORNSADDRESS

// This transaction sets up an account to use Nifty Horns
// by storing an empty card collection and creating
// a public capability for it

transaction {

    prepare(acct: AuthAccount) {

        // First, check to see if a card collection already exists
        if acct.borrow<&NiftyHorns.Collection>(from: /storage/CardCollection) == nil {

            // create a new NiftyHorns Collection
            let collection <- NiftyHorns.createEmptyCollection() as! @NiftyHorns.Collection

            // Put the new Collection in storage
            acct.save(<-collection, to: /storage/CardCollection)

            // create a public capability for the collection
            acct.link<&{NiftyHorns.CardCollectionPublic}>(/public/CardCollection, target: /storage/CardCollection)
        }
    }
}