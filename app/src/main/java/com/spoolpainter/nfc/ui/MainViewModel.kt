package com.spoolpainter.nfc.ui

import android.content.Context
import androidx.compose.runtime.*
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch
import com.spoolpainter.nfc.data.OpenSpoolData
import com.spoolpainter.nfc.spoolman.SpoolmanFilament
import com.spoolpainter.nfc.spoolman.SpoolmanService

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
        return OpenSpoolData(
            type = filament.material,
            colorHex = filament.color_hex.removePrefix("#"),
            brand = filament.vendor?.name ?: "Unknown",
            minTemp = filament.settings_extruder_temp?.toString() ?: "200",
            maxTemp = (filament.settings_extruder_temp?.plus(20))?.toString() ?: "220",
            bedMinTemp = filament.settings_bed_temp?.toString(),
            bedMaxTemp = filament.settings_bed_temp?.toString()
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
