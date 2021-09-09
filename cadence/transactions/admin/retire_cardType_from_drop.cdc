import NiftyHorns from 0xNIFTYHORNSADDRESS

// This transaction is for retiring a cardType from a drop, which
// makes it so that cards can no longer be minted from that edition

// Parameters:
//
// dropID: the ID of the drop in which a cardType is to be retired
// cardTypeID: the ID of the cardType to be retired

transaction(dropID: UInt32, cardTypeID: UInt32) {

    // local variable for storing the reference to the admin resource
    let adminRef: &NiftyHorns.Admin

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&NiftyHorns.Admin>(from: /storage/NiftyHornsAdmin)
            ?? panic("No admin resource in storage")
    }

    execute {

        // borrow a reference to the specified drop
        let dropRef = self.adminRef.borrowDrop(dropID: dropID)

        // retire the cardType
        dropRef.retireCardType(cardTypeID: cardTypeID)
    }

    post {

        self.adminRef.borrowDrop(dropID: dropID).retired[cardTypeID]!:
            "cardType is not retired"
    }
}