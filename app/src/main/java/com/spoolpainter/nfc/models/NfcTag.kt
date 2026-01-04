package com.spoolpainter.nfc.models

data class NfcTag(
    val id: String,
    val data: String? = null,
    val isWritable: Boolean = true
)
