import NiftyHorns from 0xNIFTYHORNSADDRESS

// This transaction is how a Nifty Horns admin adds a created cardType to a drop

// Parameters:
//
// dropID: the ID of the drop to which a created cardType is added
// cardTypeID: the ID of the cardType being added

transaction(dropID: UInt32, cardTypeID: UInt32) {

    // Local variable for the Nifty Horns Admin object
    let adminRef: &NiftyHorns.Admin

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&NiftyHorns.Admin>(from: /storage/NiftyHornsAdmin)
            ?? panic("Could not borrow a reference to the Admin resource")
    }

    execute {

        // Borrow a reference to the drop to be added to
        let dropRef = self.adminRef.borrowDrop(dropID: dropID)

        // Add the specified cardType ID
        dropRef.addCardType(cardTypeID: cardTypeID)
    }

    post {

        NiftyHorns.getCardTypesInDrop(dropID: dropID)!.contains(cardTypeID):
            "drop does not contain cardTypeID"
    }
}