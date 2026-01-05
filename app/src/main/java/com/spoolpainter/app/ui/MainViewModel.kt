package com.spoolpainter.app.ui

import android.content.Context
import androidx.compose.runtime.*
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch
import com.spoolpainter.app.data.local.OpenSpoolData
import com.spoolpainter.app.domain.models.SpoolmanFilament
import com.spoolpainter.app.data.remote.spoolman.SpoolmanService
import com.spoolpainter.app.data.local.MaterialDatabase

class MainViewModel : ViewModel() {
    
    // UI State
    var readData by mutableStateOf<OpenSpoolData?>(null)
        private set
    var dataVersion by mutableStateOf(0)
        private set
    var snackbarMessage by mutableStateOf("")
        private set
    var showSnackbar by mutableStateOf(false)
        private set
    var showSettings by mutableStateOf(false)
        private set
    
    // Spoolman State
    var spoolmanUrl by mutableStateOf("")
        private set
    var spoolmanFilaments by mutableStateOf<List<SpoolmanFilament>>(emptyList())
        private set
    var selectedSpoolmanFilament by mutableStateOf<SpoolmanFilament?>(null)
        private set
    var isLoadingSpools by mutableStateOf(false)
        private set

    fun loadSpoolmanUrl(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        spoolmanUrl = prefs.getString(SPOOLMAN_URL_KEY, DEFAULT_URL) ?: DEFAULT_URL
        
        if (isValidSpoolmanUrl(spoolmanUrl)) {
            loadSpoolmanFilaments()
        }
    }

    fun handleNfcTagDetected(data: String?) {
        data?.let { 
            OpenSpoolData.fromJson(it)?.let { openSpoolData ->
                readData = openSpoolData
                dataVersion++
            }
        }
    }

    fun showSnackbarMessage(message: String) {
        snackbarMessage = message
        showSnackbar = true
    }

    fun dismissSnackbar() {
        showSnackbar = false
    }

    fun showSettings() {
        showSettings = true
    }

    fun hideSettings() {
        showSettings = false
    }

    fun handleSettingsSave(context: Context, newUrl: String) {
        spoolmanUrl = newUrl
        saveSpoolmanUrl(context, newUrl)
        
        if (isValidSpoolmanUrl(newUrl)) {
            loadSpoolmanFilaments()
        }
        
        showSettings = false
    }

    fun handleFilamentSelection(filament: SpoolmanFilament) {
        selectedSpoolmanFilament = filament
        val openSpoolData = createOpenSpoolDataFromFilament(filament)
        readData = openSpoolData
        dataVersion++
    }

    private fun saveSpoolmanUrl(context: Context, url: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putString(SPOOLMAN_URL_KEY, url).apply()
    }

    private fun isValidSpoolmanUrl(url: String): Boolean {
        return url != DEFAULT_URL && url.isNotEmpty()
    }

    private fun createOpenSpoolDataFromFilament(filament: SpoolmanFilament): OpenSpoolData {
        val material = MaterialDatabase.getMaterial(filament.material)
        val spoolmanTemp = filament.settings_extruder_temp
        val spoolmanBedTemp = filament.settings_bed_temp
        
        val (minTemp, maxTemp) = if (spoolmanTemp != null && material != null) {
            if (spoolmanTemp in material.defaultMinTemp..material.defaultMaxTemp) {
                // Use default range if Spoolman temp falls within it
                material.defaultMinTemp.toString() to material.defaultMaxTemp.toString()
            } else {
                // Use Spoolman temp +20 if outside default range
                spoolmanTemp.toString() to (spoolmanTemp + 20).toString()
            }
        } else {
            // Fallback to material defaults or generic range
            material?.let { it.defaultMinTemp.toString() to it.defaultMaxTemp.toString() } 
                ?: ("200" to "220")
        }
        
        val (bedMinTemp, bedMaxTemp) = if (spoolmanBedTemp != null && material != null) {
            if (spoolmanBedTemp in material.defaultBedMinTemp..material.defaultBedMaxTemp) {
                // Use default range if Spoolman bed temp falls within it
                material.defaultBedMinTemp.toString() to material.defaultBedMaxTemp.toString()
            } else {
                // Use Spoolman bed temp +10 if outside default range
                spoolmanBedTemp.toString() to (spoolmanBedTemp + 10).toString()
            }
        } else {
            // Fallback to material defaults or generic range
            material?.let { it.defaultBedMinTemp.toString() to it.defaultBedMaxTemp.toString() } 
                ?: ("50" to "70")
        }
        
        return OpenSpoolData(
            type = filament.material,
            colorHex = filament.color_hex.removePrefix("#"),
            brand = filament.vendor?.name ?: "Unknown",
            minTemp = minTemp,
            maxTemp = maxTemp,
            bedMinTemp = bedMinTemp,
            bedMaxTemp = bedMaxTemp
        )
    }

    private fun loadSpoolmanFilaments() {
        isLoadingSpools = true
        viewModelScope.launch {
            try {
                val service = SpoolmanService(spoolmanUrl)
                spoolmanFilaments = service.getFilaments()
            } catch (e: Exception) {
                spoolmanFilaments = emptyList()
            } finally {
                isLoadingSpools = false
            }
        }
    }

    companion object {
        private const val PREFS_NAME = "spoolpainter_prefs"
        private const val SPOOLMAN_URL_KEY = "spoolman_url"
        private const val DEFAULT_URL = "http://192.168.1."
    }
}
