package com.spoolpainter.nfc.ui

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowDropDown
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.spoolpainter.nfc.spoolman.SpoolmanFilament

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SpoolmanFilamentDropdown(
    filaments: List<SpoolmanFilament>,
    selectedFilament: SpoolmanFilament?,
    onFilamentSelected: (SpoolmanFilament) -> Unit,
    isLoading: Boolean = false,
    modifier: Modifier = Modifier
) {
    var expanded by remember { mutableStateOf(false) }
    
    ExposedDropdownMenuBox(
        expanded = expanded,
        onExpandedChange = { expanded = !expanded && filaments.isNotEmpty() },
        modifier = modifier
    ) {
        OutlinedTextField(
            value = selectedFilament?.let { "${it.vendor?.name ?: "Unknown"} - ${it.name}" } ?: "",
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
            modifier = Modifier
                .menuAnchor()
                .fillMaxWidth(),
            enabled = !isLoading && filaments.isNotEmpty()
        )
        
        ExposedDropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false }
        ) {
            filaments.forEach { filament ->
                DropdownMenuItem(
                    text = { 
                        Column {
                            Text("${filament.vendor?.name ?: "Unknown"} - ${filament.name}")
                            Text(
                                text = filament.material,
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
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
