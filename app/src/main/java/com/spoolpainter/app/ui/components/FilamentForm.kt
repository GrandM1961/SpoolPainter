package com.spoolpainter.app.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

@Composable
fun FilamentForm(
    filamentType: String,
    customMaterial: String,
    variant: String,
    colorHex: String?,
    brand: String,
    customBrand: String,
    onFilamentTypeChange: (String, String, String, String, String) -> Unit,
    onCustomMaterialChange: (String) -> Unit,
    onVariantChange: (String) -> Unit,
    onColorChange: (String?) -> Unit,
    onBrandChange: (String) -> Unit,
    onCustomBrandChange: (String) -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
        MaterialSelector(
            selectedMaterial = filamentType,
            customMaterial = customMaterial,
            onMaterialSelected = onFilamentTypeChange,
            onCustomMaterialChange = onCustomMaterialChange
        )

        OutlinedTextField(
            value = variant,
            onValueChange = { input ->
                // Sanitize input: alphanumeric, spaces, hyphens, plus signs only
                val sanitized = input.filter { it.isLetterOrDigit() || it in " -+" }
                    .take(25) // Max 10 characters
                    .replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() }
                onVariantChange(sanitized)
            },
            label = { Text("Variant (Wood, Pro, HS, etc.)") },
            placeholder = { Text("Optional") },
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

        ColorSelector(
            selectedColor = colorHex,
            onColorSelected = onColorChange
        )

        BrandSelector(
            selectedBrand = brand,
            customBrand = customBrand,
            onBrandSelected = onBrandChange,
            onCustomBrandChange = onCustomBrandChange
        )

    }
}
