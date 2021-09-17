module github.com/blockcolabs/nifty-horns-contracts-repo/cadence/lib/go/test

go 1.16

require (
	github.com/blockcolabs/nifty-horns-contracts-repo/cadence/lib/go/contracts v0.0.0-20210917005620-3661cdf337b2
	github.com/blockcolabs/nifty-horns-contracts-repo/cadence/lib/go/templates v0.0.0-20210917005620-3661cdf337b2
	github.com/onflow/cadence v0.18.0
	github.com/onflow/flow-emulator v0.21.0
	github.com/onflow/flow-go-sdk v0.20.0
	github.com/stretchr/testify v1.7.0
)

replace github.com/blockcolabs/nifty-horns-contracts-repo/cadence/lib/go/templates => ../templates

replace github.com/blockcolabs/nifty-horns-contracts-repo/cadence/lib/go/contracts => ../contracts
