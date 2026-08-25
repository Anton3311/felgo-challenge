import QtQuick
import Felgo

// This component implements health tracking + damage handling
//
// Can be shared by both the player and the enemies

Item {
    property int health
    property int maxHealth

    Component.onCompleted: {
        health = maxHealth
    }

    signal damageApplied(damage: int)
    signal death

    function applyDamage(damage) {
        // Clamp the damage, so that the health doesn't become negative
        //
        // Also when reporting damage to the event system, we want to
        // send the actual damage amount that was applied
        if (damage > health) {
            damage = health
        }

        if (damage > 0) {
            health -= damage;
            damageApplied(damage);
        }

        if (health == 0) {
            death()
        }
    }
}
