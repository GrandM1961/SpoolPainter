package com.spoolpainter.nfc.data

import com.spoolpainter.nfc.models.Material

object MaterialDatabase {
    val materials = listOf(
        Material("PLA", 190, 220),
        Material("ABS", 220, 260),
        Material("PETG", 220, 250),
        Material("TPU", 210, 230),
        Material("ASA", 240, 270),
        Material("PC", 270, 310),
        Material("Nylon", 240, 280),
        Material("PVA", 180, 210),
        Material("HIPS", 220, 260),
        Material("Other", 200, 220)
    )
    
    fun getMaterial(name: String): Material? = materials.find { it.name == name }
}
