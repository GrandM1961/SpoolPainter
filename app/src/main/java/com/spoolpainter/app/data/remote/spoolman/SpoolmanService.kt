package com.spoolpainter.app.data.remote.spoolman

import android.util.Log
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET

interface SpoolmanApi {
    @GET("api/v1/spool")
    suspend fun getSpools(): Response<List<SpoolmanSpool>>
}

class SpoolmanService(private val baseUrl: String) {
    private val api = Retrofit.Builder()
        .baseUrl(if (baseUrl.endsWith("/")) baseUrl else "$baseUrl/")
        .addConverterFactory(GsonConverterFactory.create())
        .build()
        .create(SpoolmanApi::class.java)
    
    suspend fun getFilaments(): List<SpoolmanFilament> {
        return try {
            Log.d("SpoolmanService", "Fetching spools from: $baseUrl")
            val response = api.getSpools()
            Log.d("SpoolmanService", "Response code: ${response.code()}")
            
            if (response.isSuccessful) {
                val spools = response.body() ?: emptyList()
                Log.d("SpoolmanService", "Found ${spools.size} spools")
                
                spools.map { spool ->
                    Log.d("SpoolmanService", "Spool: ${spool.filament.vendor?.name} - ${spool.filament.name}")
                    SpoolmanFilament(
                        id = spool.filament.id ?: 0,
                        name = spool.filament.name,
                        material = spool.filament.material,
                        vendor = spool.filament.vendor,
                        color_hex = spool.filament.color_hex,
                        settings_extruder_temp = spool.filament.settings_extruder_temp,
                        settings_bed_temp = spool.filament.settings_bed_temp
                    )
                }
            } else {
                Log.e("SpoolmanService", "Request failed: ${response.code()} - ${response.message()}")
                emptyList()
            }
        } catch (e: Exception) {
            Log.e("SpoolmanService", "Exception: ${e.message}", e)
            emptyList()
        }
    }
}
