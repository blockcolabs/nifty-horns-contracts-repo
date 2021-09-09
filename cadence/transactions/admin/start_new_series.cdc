import NiftyHorns from 0xNIFTYHORNSADDRESS

// This transaction is for an Admin to start a new Nifty Horns series

transaction {

    // Local variable for the Nifty Horns Admin object
    let adminRef: &NiftyHorns.Admin
    let currentSeries: UInt32

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&NiftyHorns.Admin>(from: /storage/NiftyHornsAdmin)
            ?? panic("No admin resource in storage")

        self.currentSeries = NiftyHorns.currentSeries
    }

    execute {

        // Increment the series number
        self.adminRef.startNewSeries()
    }

    post {

        NiftyHorns.currentSeries == self.currentSeries + 1 as UInt32:
            "new series not started"
    }
}