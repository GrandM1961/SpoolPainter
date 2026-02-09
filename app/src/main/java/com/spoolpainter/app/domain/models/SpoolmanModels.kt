package com.spoolpainter.app.domain.models

data class SpoolmanSpool(
    val id: Int? = null,
    val filament: SpoolmanFilament,
    val remaining_weight: Float? = null,
    val used_weight: Float = 0f,
    val location: String? = null,
    val lot_nr: String? = null,
    val archived: Boolean = false
)

data class SpoolmanFilament(
    val id: Int,
    val name: String,
    val material: String,
    val vendor: SpoolmanVendor?,
    val color_hex: String,
    val settings_extruder_temp: Int?,
    val settings_bed_temp: Int?
)

data class SpoolmanVendor(
    val name: String
)

data class SpoolmanResponse<T>(
    val items: List<T>
)
