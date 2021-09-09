import NiftyHorns from 0xNIFTYHORNSADDRESS

// This transaction is for the admin to create a new drop resource
// and store it in the Nifty Horns smart contract

// Parameters:
//
// dropName: the name of a new Drop to be created

transaction(dropName: String) {

    // Local variable for the Nifty Horns Admin object
    let adminRef: &NiftyHorns.Admin
    let currDropID: UInt32

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&NiftyHorns.Admin>(from: /storage/NiftyHornsAdmin)
            ?? panic("Could not borrow a reference to the Admin resource")
        self.currDropID = NiftyHorns.nextDropID;
    }

    execute {

        // Create a drop with the specified name
        self.adminRef.createDrop(name: dropName)
    }

    post {

        NiftyHorns.getDropName(dropID: self.currDropID) == dropName:
          "Could not find the specified drop"
    }
}