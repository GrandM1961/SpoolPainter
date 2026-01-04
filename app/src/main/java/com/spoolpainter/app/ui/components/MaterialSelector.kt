package com.spoolpainter.app.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.spoolpainter.app.data.local.MaterialDatabase

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MaterialSelector(
    selectedMaterial: String,
    customMaterial: String,
    onMaterialSelected: (String, String, String) -> Unit,
    onCustomMaterialChange: (String) -> Unit
) {
    var expanded by remember { mutableStateOf(false) }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(IntrinsicSize.Min),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        ExposedDropdownMenuBox(
            expanded = expanded,
            onExpandedChange = { expanded = !expanded },
            modifier = if (selectedMaterial == "Other") Modifier.width(120.dp) else Modifier.fillMaxWidth()
        ) {
            OutlinedTextField(
                value = selectedMaterial,
                onValueChange = { },
                readOnly = true,
                label = { Text("Filament Type") },
                trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) },
                modifier = Modifier.menuAnchor().fillMaxWidth(),
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
                MaterialDatabase.materials.forEach { material ->
                    DropdownMenuItem(
                        text = { Text(material.name) },
                        onClick = {
                            expanded = false
                            onMaterialSelected(material.name, material.defaultMinTemp.toString(), material.defaultMaxTemp.toString())
                        }
                    )
                }
            }
        }

        if (selectedMaterial == "Other") {
            OutlinedTextField(
                value = customMaterial,
                onValueChange = { input ->
                    // Sanitize input: alphanumeric, hyphens, plus signs only (no spaces)
                    val sanitized = input.filter { it.isLetterOrDigit() || it in "-+" }
                        .take(8) // Max 5 characters
                        .uppercase()
                    onCustomMaterialChange(sanitized)
                },
                label = { Text("Custom Material") },
                singleLine = true,
                modifier = Modifier.fillMaxWidth(),
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
        }
    }
}
