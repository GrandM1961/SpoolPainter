package com.spoolpainter.nfc.ui

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    spoolmanUrl: String,
    onSpoolmanUrlChange: (String) -> Unit,
    onSave: (String) -> Unit,
    onBack: () -> Unit
) {
    var tempUrl by remember { mutableStateOf(spoolmanUrl) }
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
            onValueChange = { if (it.length <= 50) tempUrl = it },
            label = { Text("Spoolman Server URL") },
            placeholder = { Text("http://192.168.1.100:7912") },
            supportingText = { Text("${tempUrl.length}/50") },
            singleLine = true,
            modifier = Modifier.fillMaxWidth()
        )
        
        Text(
            text = "Enter your local Spoolman server URL",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(top = 8.dp)
        )
        
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
                onClick = { onSave(tempUrl) },
                modifier = Modifier.weight(1f)
            ) {
                Text("Save")
            }
        }
    }
}
