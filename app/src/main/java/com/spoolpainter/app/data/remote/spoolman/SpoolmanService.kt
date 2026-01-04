package com.spoolpainter.app.data.remote.spoolman

import android.util.Log
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import com.spoolpainter.app.domain.models.SpoolmanSpool
import com.spoolpainter.app.domain.models.SpoolmanFilament
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import java.util.concurrent.TimeUnit

interface SpoolmanApi {
    @GET("api/v1/spool")
    suspend fun getSpools(): Response<List<SpoolmanSpool>>
}

class SpoolmanService(private val baseUrl: String) {
    private var cachedFilaments: List<SpoolmanFilament>? = null
    private var lastFetchTime = 0L
    private val cacheValidityMs = 30_000L // 30 seconds
    
    private val client = OkHttpClient.Builder()
        .connectTimeout(3, TimeUnit.SECONDS)
        .readTimeout(5, TimeUnit.SECONDS)
        .build()
    
    private val api = Retrofit.Builder()
        .baseUrl(if (baseUrl.endsWith("/")) baseUrl else "$baseUrl/")
        .client(client)
        .addConverterFactory(GsonConverterFactory.create())
        .build()
        .create(SpoolmanApi::class.java)
    
    suspend fun getFilaments(): List<SpoolmanFilament> {
        val now = System.currentTimeMillis()
        
        // Return cached data if still valid
        cachedFilaments?.let { cached ->
            if (now - lastFetchTime < cacheValidityMs) {
                return cached
            }
        }
        
        return try {
            val response = api.getSpools()
            
            if (response.isSuccessful) {
                val filaments = response.body()?.map { spool ->
                    SpoolmanFilament(
                        id = spool.filament.id ?: 0,
                        name = spool.filament.name,
                        material = spool.filament.material,
                        vendor = spool.filament.vendor,
                        color_hex = spool.filament.color_hex,
                        settings_extruder_temp = spool.filament.settings_extruder_temp,
                        settings_bed_temp = spool.filament.settings_bed_temp
                    )
                } ?: emptyList()
                
                cachedFilaments = filaments
                lastFetchTime = now
                filaments
            } else {
                cachedFilaments ?: emptyList()
            }
        } catch (e: Exception) {
            cachedFilaments ?: emptyList()
        }
    }
}
