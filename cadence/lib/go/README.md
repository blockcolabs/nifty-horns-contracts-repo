# Nifty Horns Go Packages

This directory conains packages for interacting with the Nifty Horns
smart contracts from a Go programming environment.

# Package Guides

- `contracts`: Contains functions to generate the text of the contract code
for the contracts in the `/nifty-horns-contracts-repo/cadence/contracts` directory.
To generate the contracts:
1. Fetch the `contracts` package: `go get github.com/blockcolabs/nifty-horns-contracts-repo/cadence/contracts`
2. Import the package at the top of your Go File: `import "github.com/blockcolabs/nifty-horns-contracts-repo/cadence/lib/go/contracts"`
3. Call the `GenerateNiftyHornsContract` and others to generate the full text of the contracts.
- `events`: Contains go definitions for the events that are emitted by
the Nifty Horns contracts so that these events can be monitored by applications.
- `templates`: Contains functions to return transaction templates
for common transactions and scripts for interacting with the Nifty Horns
smart contracts.
If you want to import the transactions in your Go programs
so you can submit them to interact with the Nifty Horns smart contracts,
you can do so with the `templates` package:
1. Fetch the `templates` package: `go get github.com/blockcolabs/nifty-horns-contracts-repo/cadence/templates`
2. Import the package at the top of your Go File: `import "github.com/blockcolabs/nifty-horns-contracts-repo/cadence/lib/go/templates"`
3. Call the various functions in the `templates` package like `templates.GenerateTransferCardScript()` and others to generate the full text of the templates that you can fill in with your arguments.
- `templates/data`: Contains go constructs for representing cardType metadata
for Nifty Horns cardTypes on chain.
- `test`: Contains automated go tests for testing the functionality
of the Nifty Horns smart contracts.