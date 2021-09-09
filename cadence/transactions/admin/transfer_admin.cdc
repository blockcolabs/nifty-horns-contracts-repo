import NiftyHorns from 0xNIFTYHORNSADDRESS
import NiftyHornsAdminReceiver from 0xADMINRECEIVERADDRESS

// this transaction takes a NiftyHorns Admin resource and
// saves it to the account storage of the account
// where the contract is deployed

transaction {

    // Local variable for the Nifty Horns Admin object
    let adminRef: @NiftyHorns.Admin

    prepare(acct: AuthAccount) {

        self.adminRef <- acct.load<@NiftyHorns.Admin>(from: /storage/NiftyHornsAdmin)
            ?? panic("No Nifty Horns admin in storage")
    }

    execute {

        NiftyHornsAdminReceiver.storeAdmin(newAdmin: <-self.adminRef)
    }
}