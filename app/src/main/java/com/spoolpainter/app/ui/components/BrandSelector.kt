package com.spoolpainter.app.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import com.spoolpainter.app.data.local.BrandDatabase

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BrandSelector(
    selectedBrand: String,
    customBrand: String,
    onBrandSelected: (String) -> Unit,
    onCustomBrandChange: (String) -> Unit
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
            modifier = if (selectedBrand == "Other") Modifier.width(120.dp) else Modifier.fillMaxWidth()
        ) {
            OutlinedTextField(
                value = selectedBrand,
                onValueChange = { },
                readOnly = true,
                label = { Text("Brand") },
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
                modifier = Modifier
                    .zIndex(1f)
                    .clip(RoundedCornerShape(20.dp)),
                tonalElevation = 8.dp
            ) {
                BrandDatabase.brands.forEach { brand ->
                    DropdownMenuItem(
                        text = { Text(brand) },
                        onClick = {
                            expanded = false
                            onBrandSelected(brand)
                        }
                    )
                }
            }
        }

        if (selectedBrand == "Other") {
            OutlinedTextField(
                value = customBrand,
                onValueChange = { input ->
                    // Sanitize input: alphanumeric, spaces, periods, hyphens only
                    val sanitized = input.filter { it.isLetterOrDigit() || it in " .-" }
                        .take(10) // Max 10 characters for brand names
                        .replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() }
                    onCustomBrandChange(sanitized)
                },
                label = { Text("Custom Brand") },
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
