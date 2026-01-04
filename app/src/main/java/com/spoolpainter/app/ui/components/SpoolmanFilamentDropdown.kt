package com.spoolpainter.app.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.spoolpainter.app.domain.models.SpoolmanFilament

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
                        Text("${filament.vendor?.name ?: "Unknown"} - ${filament.name}")
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
