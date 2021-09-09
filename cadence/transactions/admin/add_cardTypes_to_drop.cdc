import NiftyHorns from 0xNIFTYHORNSADDRESS

// This transaction adds multiple cardTypes to a drop

// Parameters:
//
// dropID: the ID of the drop to which multiple cardTypes are added
// cardTypes: an array of cardType IDs being added to the drop

transaction(dropID: UInt32, cardTypes: [UInt32]) {

    // Local variable for the Nifty Horns Admin object
    let adminRef: &NiftyHorns.Admin

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&NiftyHorns.Admin>(from: /storage/NiftyHornsAdmin)!
    }

    execute {

        // borrow a reference to the drop to be added to
        let dropRef = self.adminRef.borrowDrop(dropID: dropID)

        // Add the specified cardType IDs
        dropRef.addCardTypes(cardTypeIDs: cardTypes)
    }
}