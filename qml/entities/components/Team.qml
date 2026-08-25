import QtQuick
import Felgo

// This is a little component used to tell who can damage whom.
//
// For example when the player shoot, the bullet gets the same team instance as the player, and upon
// collision with any entity of the different team, the bullet will apply damage.

Item {
    property string debugName

	// The category for entities of this team.
	property int entityCategory
	// Categories of entities members of this team are allowed to collide with.
	property int entityCollisionCategories

	property int bulletCategory
	property int bulletCollisionCategories
}
