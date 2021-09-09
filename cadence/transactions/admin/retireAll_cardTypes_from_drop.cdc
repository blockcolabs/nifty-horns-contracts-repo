import NiftyHorns from 0xNIFTYHORNSADDRESS

// This transaction is for retiring all cardTypes from a drop, which
// makes it so that cards can no longer be minted
// from all the editions with that drop

// Parameters:
//
// dropID: the ID of the drop to be retired entirely

transaction(dropID: UInt32) {
    let adminRef: &NiftyHorns.Admin

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&NiftyHorns.Admin>(from: /storage/NiftyHornsAdmin)
            ?? panic("No admin resource in storage")
    }

    execute {
        // borrow a reference to the specified drop
        let dropRef = self.adminRef.borrowDrop(dropID: dropID)

        // retire all the cardTypes
        dropRef.retireAll()
    }
}