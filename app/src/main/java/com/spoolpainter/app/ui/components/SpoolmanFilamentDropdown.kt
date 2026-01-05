package com.spoolpainter.app.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.spoolpainter.app.domain.models.FilamentSpool
import com.spoolpainter.app.data.remote.spoolman.SpoolmanService

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SpoolmanFilamentDropdown(
    filaments: List<FilamentSpool>,
    selectedFilament: FilamentSpool?,
    onFilamentSelected: (FilamentSpool) -> Unit,
    spoolmanUrl: String,
    currentSpoolId: String?,
    isLoading: Boolean = false,
    modifier: Modifier = Modifier
) {
    var expanded by remember { mutableStateOf(false) }
    
    LaunchedEffect(currentSpoolId, spoolmanUrl) {
        android.util.Log.d("SpoolmanDropdown", "LaunchedEffect triggered - spoolId: $currentSpoolId, url: $spoolmanUrl")
        currentSpoolId?.let { spoolId ->
            if (spoolmanUrl.isNotEmpty()) {
                android.util.Log.d("SpoolmanDropdown", "Attempting to find filament for spool ID: $spoolId")
                try {
                    val service = SpoolmanService(spoolmanUrl)
                    val filament = service.findFilamentBySpoolId(spoolId)
                    android.util.Log.d("SpoolmanDropdown", "Found filament: $filament")
                    filament?.let { 
                        android.util.Log.d("SpoolmanDropdown", "Calling onFilamentSelected with: ${it.spoolmanName}")
                        onFilamentSelected(it)
                    } ?: android.util.Log.w("SpoolmanDropdown", "No filament found for spool ID: $spoolId")
                } catch (e: Exception) {
                    android.util.Log.e("SpoolmanDropdown", "Error finding filament for spool ID: $spoolId", e)
                }
            } else {
                android.util.Log.w("SpoolmanDropdown", "Spoolman URL is empty")
            }
        } ?: android.util.Log.d("SpoolmanDropdown", "No spool ID provided")
    }
    
    ExposedDropdownMenuBox(
        expanded = expanded,
        onExpandedChange = { expanded = !expanded && filaments.isNotEmpty() },
        modifier = modifier
    ) {
        OutlinedTextField(
            value = selectedFilament?.let { "${it.brand} - ${it.spoolmanName} - ${it.material}" } ?: "",
            onValueChange = { },
            readOnly = true,
            label = { Text("Select from Spoolman") },
            trailingIcon = {
                if (isLoading) {
                    CircularProgressIndicator(modifier = Modifier.size(20.dp))
                } else {
                    ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded)
                }
            },
            modifier = Modifier.menuAnchor().fillMaxWidth(),
            enabled = !isLoading && filaments.isNotEmpty(),
            textStyle = MaterialTheme.typography.bodyLarge.copy(
                fontWeight = FontWeight.SemiBold
            ),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = MaterialTheme.colorScheme.primary,
                unfocusedBorderColor = MaterialTheme.colorScheme.outline,
                focusedTextColor = MaterialTheme.colorScheme.onSurface,
                unfocusedTextColor = MaterialTheme.colorScheme.onSurface
            ),
            shape = RoundedCornerShape(20.dp)
        )
        
        ExposedDropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false },
            modifier = Modifier.clip(RoundedCornerShape(20.dp)),
            tonalElevation = 8.dp
        ) {
            filaments.take(50).forEach { filament ->
                DropdownMenuItem(
                    text = { 
                        Text("${filament.brand} - ${filament.spoolmanName} - ${filament.material}")
                    },
                    onClick = {
                        onFilamentSelected(filament)
                        expanded = false
                    }
                )
            }
        }
    }
}
