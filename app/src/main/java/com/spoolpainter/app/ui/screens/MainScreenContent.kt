package com.spoolpainter.app.ui.screens

import androidx.compose.runtime.Composable
import com.spoolpainter.app.ui.MainViewModel


@Composable
fun MainScreenContent(
    viewModel: MainViewModel,
    onWriteTag: (String) -> Unit,
    onReadTag: () -> Unit
) {
    val context = androidx.compose.ui.platform.LocalContext.current
    
    if (viewModel.showSettings) {
        SettingsScreen(
            spoolmanUrl = viewModel.spoolmanUrl,
            onSpoolmanUrlChange = { },
            onSave = { newUrl -> 
                viewModel.handleSettingsSave(context, newUrl)
            },
            onBack = { viewModel.hideSettings() }
        )
    } else {
        SpoolPainterScreen(
            onWriteTag = onWriteTag,
            onReadTag = onReadTag,
            readData = viewModel.readData,
            dataVersion = viewModel.dataVersion,
            snackbarMessage = viewModel.snackbarMessage,
            showSnackbar = viewModel.showSnackbar,
            onSnackbarDismiss = { viewModel.dismissSnackbar() },
            onSettingsClick = { viewModel.showSettings() },
            spoolmanFilaments = viewModel.spoolmanFilaments,
            isLoadingSpools = viewModel.isLoadingSpools,
            onSpoolmanFilamentSelected = { filament ->
                viewModel.handleFilamentSelection(filament)
            }
        )
    }
}
