extends Object

# This file is for defining map tiles and the various interactions/characteristics

enum TileTypes {
	None = 0,
	GroundDirt,
	GroundGrass,
	GroundSnow,
	GroundStone,
	GroundStoneWet,
	GroundStreet,
	GroundStreetWet,
	GroundIce,
	Water,
	# TODO: Buildings may need some rethinking, depends on variety of buildings needed
	BuildingA_1,
	BuildingA_2,
	BuildingB_1,
	BuildingB_2,
	BuildingB_3,
	BuildingC_1,
	BuildingC_2,
	BuildingC_3,
	BuildingC_4,
	NumTileTypes,
	Invalid
}

# TODO: Determine if these cause damage to characters or do they just
# 	influence stats
enum TileStatus {
	None = 0,
	Electrified,
	Burning,
	Frozen,
	NumTileStatus,
	Invalid
}

var type = TileTypes.Invalid
var status = TileStatus.Invalid

# Tiles like water and things will hurt dodging, while surfaces like stone/street
# might help
var dodge_modifier = 0

# More likely to be used, for example, an electrified wet street could boost
# tech damage and hurt tech defense while standing on grass could hurt tech
# damage while boosting tech defense
var tech_defense_modifier = 0
var tech_attack_modifier = 0

# These are likely to be rarely used
var phys_defense_modifier = 0
var phys_attack_modifier = 0
