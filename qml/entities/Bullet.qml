import QtQuick
import Felgo

EntityBase {
    id: bullet
    entityId: "entity"
    entityType: "bullet"

    property int radius: 4
    property point initialImpulse: Qt.point(0, 0)

    CircleCollider {
        id: collider
        radius: bullet.radius
        bodyType: Body.Dynamic
        collidesWith: Box.Category2
        linearDamping: 0.1
        fixture.onBeginContact: {
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
