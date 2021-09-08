/*
 * Nifty Horns Admin Receiver
 *
 * This contract defines a function that takes a Nifty Horns Admin
 * object and stores it in the storage of the contract account so
 * it can be used.
 *
 */

import NiftyHorns from 0xNIFTYHORNSADDRESS

pub contract NiftyHornsAdminReceiver {

    // storeAdmin takes a NiftyHorns Admin resource and 
    // saves it to the account storage of the account
    // where the contract is deployed
    pub fun storeAdmin(newAdmin: @NiftyHorns.Admin) {
        self.account.save(<-newAdmin, to: /storage/NiftyHornsAdmin)
    }
    
    init() {
        // Save a copy of the Card Collection to the account storage
        if self.account.borrow<&NiftyHorns.Collection>(from: /storage/CardCollection) == nil {
            let collection <- NiftyHorns.createEmptyCollection()
            // Put a new Collection in storage
            self.account.save(<-collection, to: /storage/CardCollection)

            self.account.link<&{NiftyHorns.CardCollectionPublic}>(/public/CardCollection, target: /storage/CardCollection)
        }
    }
}
