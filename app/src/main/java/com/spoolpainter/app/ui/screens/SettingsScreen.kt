package com.spoolpainter.app.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    spoolmanUrl: String,
    spoolmanSortBy: String,
    onSpoolmanUrlChange: (String) -> Unit,
    onSave: (String, String) -> Unit,
    onBack: () -> Unit
) {
    var tempUrl by remember { mutableStateOf(spoolmanUrl) }
    var tempSort by remember { mutableStateOf(spoolmanSortBy) }
    var sortExpanded by remember { mutableStateOf(false) }
    
    val sortOptions = mapOf(
        "" to "None",
        "filament.vendor.name:asc" to "Brand (A-Z)",
        "filament.material:asc" to "Material (A-Z)",
        "last_used:desc" to "Last Used"
    )
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        TopAppBar(
            title = { Text("Settings") },
            navigationIcon = {
                IconButton(onClick = onBack) {
                    Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                }
            }
        )
        
        Spacer(modifier = Modifier.height(16.dp))
        
        OutlinedTextField(
            value = tempUrl,
            onValueChange = { if (it.length <= 150) tempUrl = it },
            label = { Text("Spoolman Server URL") },
            placeholder = { Text("http://192.168.1.100:7912") },
            supportingText = { Text("${tempUrl.length}/150") },
            singleLine = true,
            modifier = Modifier.fillMaxWidth()
        )
        
        Text(
            text = "Enter your local Spoolman server URL",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(top = 8.dp)
        )
        
        Spacer(modifier = Modifier.height(24.dp))
        
        ExposedDropdownMenuBox(
            expanded = sortExpanded,
            onExpandedChange = { sortExpanded = !sortExpanded }
        ) {
            OutlinedTextField(
                value = sortOptions[tempSort] ?: "None",
                onValueChange = {},
                readOnly = true,
                label = { Text("Sort Spools By") },
                trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = sortExpanded) },
                modifier = Modifier.fillMaxWidth().menuAnchor(),
                singleLine = true
            )
            
            ExposedDropdownMenu(
                expanded = sortExpanded,
                onDismissRequest = { sortExpanded = false }
            ) {
                sortOptions.forEach { (value, label) ->
                    DropdownMenuItem(
                        text = { Text(label) },
                        onClick = {
                            tempSort = value
                            sortExpanded = false
                        }
                    )
                }
            }
        }
        
        Spacer(modifier = Modifier.height(32.dp))
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            OutlinedButton(
                onClick = onBack,
                modifier = Modifier.weight(1f)
            ) {
                Text("Cancel")
            }
            
            Button(
                onClick = { onSave(tempUrl, tempSort) },
                modifier = Modifier.weight(1f)
            ) {
                Text("Save")
            }
        }
    }
}
