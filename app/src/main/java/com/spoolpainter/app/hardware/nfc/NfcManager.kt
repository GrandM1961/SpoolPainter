package com.spoolpainter.app.hardware.nfc

import android.nfc.Tag
import android.nfc.tech.Ndef
import android.nfc.NdefMessage
import android.nfc.NdefRecord
import java.nio.charset.Charset

class NfcManager {
    
    fun readTag(tag: Tag): String? {
        return try {
            val ndef = Ndef.get(tag) ?: return null
            ndef.connect()
            val ndefMessage = ndef.ndefMessage
            ndef.close()
            
            ndefMessage?.records?.firstOrNull()?.let { record ->
                String(record.payload, Charset.forName("UTF-8"))
            }
        } catch (e: Exception) {
            null
        }
    }
    
    fun writeTag(tag: Tag, data: String): Boolean {
        return try {
            val ndef = Ndef.get(tag) ?: return false
            ndef.connect()
            
            val record = NdefRecord.createTextRecord("en", data)
            val message = NdefMessage(arrayOf(record))
            
            ndef.writeNdefMessage(message)
            ndef.close()
            true
        } catch (e: Exception) {
            false
        }
    }
}
