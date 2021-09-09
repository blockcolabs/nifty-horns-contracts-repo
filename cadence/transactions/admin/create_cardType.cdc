import NiftyHorns from 0xNIFTYHORNSADDRESS

// This transaction creates a new cardType struct
// and stores it in the Nifty Horns smart contract
// We currently stringify the metadata and insert it into the
// transaction string, but want to use transaction arguments soon

// Parameters:
//
// metadata: A dictionary of all the cardType metadata associated

transaction(metadata: {String: String}) {

    // Local variable for the Nifty Horns Admin object
    let adminRef: &NiftyHorns.Admin
    let currCardTypeID: UInt32

    prepare(acct: AuthAccount) {

        // borrow a reference to the admin resource
        self.currCardTypeID = NiftyHorns.nextCardTypeID;
        self.adminRef = acct.borrow<&NiftyHorns.Admin>(from: /storage/NiftyHornsAdmin)
            ?? panic("No admin resource in storage")
    }

    execute {

        // Create a cardType with the specified metadata
        self.adminRef.createCardType(metadata: metadata)
    }

    post {

        NiftyHorns.getCardTypeMetaData(cardTypeID: self.currCardTypeID) != nil:
            "cardTypeID doesnt exist"
    }
}