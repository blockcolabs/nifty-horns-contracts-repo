package data

// Cadence requires a mapping of string->string, which can be handled through json tags when marshalling.
// It also does not allow for null values, so we will be omitting them if empty
type CardTypeMetadata struct {
	PlayerName  string
	EditionType string
}

// GenerateEmptyCardType generates a cardType with all its fields
// empty except for FullName for testing
func GenerateEmptyCardType(playerName string) CardTypeMetadata {
	return CardTypeMetadata{PlayerName: playerName,
		EditionType: "",
	}
}
