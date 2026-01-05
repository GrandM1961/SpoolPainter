package com.spoolpainter.app.domain.models

data class FilamentSpool(
    val material: String,
    val variant: String = "",
    val brand: String,
    val colorHex: String,
    val minTemp: Int?,
    val maxTemp: Int?,
    val bedMinTemp: Int?,
    val bedMaxTemp: Int?
) {
    val displayName: String
        get() = if (variant.isNotEmpty()) "$material $variant" else material
}
