import NiftyHorns from 0xNIFTYHORNSADDRESS

// This transaction locks a drop so that new cardTypes can no longer be added to it

// Parameters:
//
// dropID: the ID of the drop to be locked

transaction(dropID: UInt32) {

    // local variable for the admin resource
    let adminRef: &NiftyHorns.Admin

    prepare(acct: AuthAccount) {
        // borrow a reference to the admin resource
        self.adminRef = acct.borrow<&NiftyHorns.Admin>(from: /storage/NiftyHornsAdmin)
            ?? panic("No admin resource in storage")
    }

    execute {
        // borrow a reference to the Drop
        let dropRef = self.adminRef.borrowDrop(dropID: dropID)

        // lock the drop permanently
        dropRef.lock()
    }

    post {

        NiftyHorns.isDropLocked(dropID: dropID)!:
            "Drop did not lock"
    }
}