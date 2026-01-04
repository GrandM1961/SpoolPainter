package com.spoolpainter.nfc.models

data class FilamentSpool(
    val material: String,
    val variant: String = "",
    val brand: String,
    val colorHex: String,
    val minTemp: Int,
    val maxTemp: Int
) {
    val displayName: String
        get() = if (variant.isNotEmpty()) "$material $variant" else material
}
