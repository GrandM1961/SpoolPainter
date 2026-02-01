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
    suspend fun getSpools(
        @retrofit2.http.Query("limit") limit: Int,
        @retrofit2.http.Query("offset") offset: Int = 0,
        @retrofit2.http.Query("sort") sort: String? = null
    ): Response<List<SpoolmanSpool>>
    
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
    
    companion object {
        private const val PAGE_SIZE = 10
    }
    
    suspend fun getFilaments(sortBy: String? = null): List<FilamentSpool> {
        val now = System.currentTimeMillis()
        
        // Return cached data if still valid
        cachedFilaments?.let { cached ->
            if (now - lastFetchTime < cacheValidityMs) {
                return cached
            }
        }
        
        return try {
            val allFilaments = mutableListOf<FilamentSpool>()
            var offset = 0
            
            while (true) {
                Log.d("SpoolmanService", "Fetching spools: offset=$offset, limit=$PAGE_SIZE, sort=$sortBy")
                val response = api.getSpools(PAGE_SIZE, offset, sortBy)
                
                if (response.isSuccessful) {
                    val batch = response.body()?.map { spool ->
                        FilamentSpool.fromSpoolman(spool)
                    } ?: emptyList()
                    
                    Log.d("SpoolmanService", "Received ${batch.size} spools")
                    
                    if (batch.isEmpty()) break
                    
                    allFilaments.addAll(batch)
                    
                    if (batch.size < PAGE_SIZE) break
                    
                    offset += PAGE_SIZE
                }
                else {
                    Log.e("SpoolmanService", "API call failed: ${response.code()}")
                    break
                }
            }
            
            Log.d("SpoolmanService", "Total spools loaded: ${allFilaments.size}")
            cachedFilaments = allFilaments
            lastFetchTime = now
            allFilaments
        } catch (e: Exception) {
            Log.e("SpoolmanService", "Error loading spools", e)
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
