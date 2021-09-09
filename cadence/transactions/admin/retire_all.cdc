import NiftyHorns from 0xNIFTYHORNSADDRESS

// This is a transaction an admin would use to retire all the cardTypes in a drop
// which makes it so that no more cards can be minted from the retired cardTypes

// Parameters:
//
// dropID: the ID of the drop to be retired entirely

transaction(dropID: UInt32) {

    // local variable for the admin reference
    let adminRef: &NiftyHorns.Admin

    prepare(acct: AuthAccount) {

        // borrow a reference to the admin resource
        self.adminRef = acct.borrow<&NiftyHorns.Admin>(from: /storage/NiftyHornsAdmin)
            ?? panic("No admin resource in storage")
    }

    execute {

        // borrow a reference to the specified drop
        let dropRef = self.adminRef.borrowDrop(dropID: dropID)

        // retire all the cardTypes permenantely
        dropRef.retireAll()
    }
}