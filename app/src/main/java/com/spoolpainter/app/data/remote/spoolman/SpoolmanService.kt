package com.spoolpainter.app.data.remote.spoolman

import android.util.Log
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Path
import com.spoolpainter.app.domain.models.SpoolmanSpool
import com.spoolpainter.app.domain.models.FilamentSpool
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import java.util.concurrent.TimeUnit

interface SpoolmanApi {
    @GET("api/v1/spool")
    suspend fun getSpools(): Response<List<SpoolmanSpool>>
    
    @GET("api/v1/spool/{id}")
    suspend fun getSpool(@Path("id") id: Int): Response<SpoolmanSpool>
}

class SpoolmanService(private val baseUrl: String) {
    private var cachedFilaments: List<FilamentSpool>? = null
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
    
    suspend fun getFilaments(): List<FilamentSpool> {
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
                    FilamentSpool.fromSpoolman(spool)
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
    
    suspend fun findFilamentBySpoolId(spoolId: String): FilamentSpool? {
        val id = spoolId.toIntOrNull() ?: return null
        
        // First check cached filaments
        cachedFilaments?.find { it.id == id }?.let { return it }
        
        // If not in cache, try to fetch specific spool
        return try {
            val response = api.getSpool(id)
            if (response.isSuccessful) {
                response.body()?.let { FilamentSpool.fromSpoolman(it) }
            } else null
        } catch (e: Exception) {
            null
        }
    }
}
