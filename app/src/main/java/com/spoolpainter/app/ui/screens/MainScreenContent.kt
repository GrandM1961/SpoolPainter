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
            spoolmanSortBy = viewModel.spoolmanSortBy,
            onSpoolmanUrlChange = { },
            onSave = { newUrl, newSort -> 
                viewModel.handleSettingsSave(context, newUrl, newSort)
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
            spools = viewModel.spools,
            selectedSpool = viewModel.selectedSpool,
            isLoadingSpools = viewModel.isLoadingSpools,
            onSpoolSelected = { filament ->
                viewModel.handleFilamentSelection(filament)
            },
            onRefreshSpools = { viewModel.refreshSpools() },
            spoolmanUrl = viewModel.spoolmanUrl,
            currentSpoolId = viewModel.currentSpoolId
        )
    }
}
