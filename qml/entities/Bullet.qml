import QtQuick
import Felgo

import "./components"

EntityBase {
    id: bullet
    entityId: "entity"
    entityType: "bullet"

    property int radius: 4
    property point initialImpulse: Qt.point(0, 0)
    property Team team

    CircleCollider {
        id: collider
        radius: bullet.radius
        bodyType: Body.Dynamic
		categories: team.bulletCategory
        collidesWith: team.bulletCollisionCategories
		groupIndex: -1 // make sure that bullets never collide with each other
        linearDamping: 0.1
        fixture.onBeginContact: (other, normal) => {
            let target = other.getBody().target;
            let damagable = target.damagable;
            if (damagable !== undefined) {
                if (damagable.team === bullet.team) {
                    // Completely ignore. Don't apply damage, don't self destruct
                    return;
                }

                damagable.applyDamage(1);
            }

            destroy();
        }

        MultiResolutionImage {
            anchors.centerIn: parent
            source: Qt.resolvedUrl("../../assets/entities/bullet.png")
            width: 16
            height: 16
        }
    }

	Component.onCompleted: {
		collider.applyLinearImpulse(initialImpulse, collider.body.getWorldCenter())
	}
}
