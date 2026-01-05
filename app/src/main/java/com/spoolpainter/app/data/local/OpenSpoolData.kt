package com.spoolpainter.app.data.local

import com.spoolpainter.app.domain.models.FilamentSpool
import org.json.JSONObject

data class OpenSpoolData(
    val protocol: String = "openspool",
    val version: String = "1.0",
    val type: String,
    val colorHex: String,
    val brand: String,
    val minTemp: String,
    val maxTemp: String,
    val bedMinTemp: String? = null,
    val bedMaxTemp: String? = null,
    val subtype: String = "Basic"
) {
    fun toJson(): String {
        return JSONObject().apply {
            put("protocol", protocol)
            put("version", version)
            put("type", type)
            put("color_hex", colorHex)
            put("brand", brand)
            put("min_temp", minTemp)
            put("max_temp", maxTemp)
            bedMinTemp?.let { put("bed_min_temp", it) }
            bedMaxTemp?.let { put("bed_max_temp", it) }
            if (subtype.isNotEmpty()) put("subtype", subtype)
        }.toString()
    }
    
    companion object {
        fun fromJson(json: String): OpenSpoolData? {
            return try {
                val jsonObj = JSONObject(json)
                if (jsonObj.optString("protocol") == "openspool") {
                    OpenSpoolData(
                        type = jsonObj.optString("type", "Unknown"),
                        colorHex = jsonObj.optString("color_hex", "000000"),
                        brand = jsonObj.optString("brand", "Unknown"),
                        minTemp = jsonObj.optString("min_temp", "200"),
                        maxTemp = jsonObj.optString("max_temp", "220"),
                        bedMinTemp = jsonObj.optString("bed_min_temp").takeIf { it.isNotEmpty() },
                        bedMaxTemp = jsonObj.optString("bed_max_temp").takeIf { it.isNotEmpty() },
                        subtype = jsonObj.optString("subtype", "Basic")
                    )
                } else null
            } catch (e: Exception) {
                null
            }
        }
        
        fun fromSpool(spool: FilamentSpool): OpenSpoolData {
            return OpenSpoolData(
                type = spool.displayName,
                colorHex = spool.colorHex,
                brand = spool.brand,
                minTemp = spool.minTemp.toString(),
                maxTemp = spool.maxTemp.toString()
            )
        }
    }
    
    fun toSpool(): FilamentSpool {
        val material = MaterialDatabase.getMaterial(type)
        return FilamentSpool(
            material = type,
            variant = if (subtype != "Basic") subtype else "",
            brand = brand,
            colorHex = colorHex,
            minTemp = minTemp.toIntOrNull() ?: material?.defaultMinTemp,
            maxTemp = maxTemp.toIntOrNull() ?: material?.defaultMaxTemp,
            bedMinTemp = bedMinTemp?.toIntOrNull() ?: material?.defaultBedMinTemp,
            bedMaxTemp = bedMaxTemp?.toIntOrNull() ?: material?.defaultBedMaxTemp
        )
    }
}
