package com.spoolpainter.app.hardware.nfc

import android.app.Activity
import android.app.PendingIntent
import android.content.Intent
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.widget.Toast

class NfcController(private val activity: Activity) {
    private var nfcAdapter: NfcAdapter? = null
    private var pendingIntent: PendingIntent? = null
    private var pendingWriteData: String? = null
    private val nfcManager = NfcManager()
    private var isReadingEnabled = false
    
    var onTagDetected: ((String?) -> Unit)? = null
    var onStatusUpdate: ((String, Boolean) -> Unit)? = null

    fun initialize() {
        nfcAdapter = NfcAdapter.getDefaultAdapter(activity)
        
        when {
            nfcAdapter == null -> onStatusUpdate?.invoke("NFC not supported on this device", false)
            !nfcAdapter!!.isEnabled -> onStatusUpdate?.invoke("Please enable NFC in Settings", false)
        }

        pendingIntent = PendingIntent.getActivity(
            activity, 0, Intent(activity, activity.javaClass).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP), 
            PendingIntent.FLAG_MUTABLE
        )
    }

    fun writeToCurrentTag(data: String) {
        isReadingEnabled = false // Clear any pending read
        pendingWriteData = data
        onStatusUpdate?.invoke(" Hold your phone near an NFC tag to write data", true)
    }

    private var recentTagData: String? = null
    private var tagDetectedTime: Long = 0
    private val TAG_MEMORY_DURATION = 5000L // 5 seconds

    fun enableReading() {
        // Check if we have a recent tag first
        if (hasRecentTag()) {
            onTagDetected?.invoke(recentTagData)
            onStatusUpdate?.invoke("✅ Tag data loaded!", false)
            clearRecentTag()
            return
        }
        
        pendingWriteData = null // Clear any pending write
        isReadingEnabled = true
        onStatusUpdate?.invoke(" Hold your phone near an NFC tag to read data", true)
    }

    private fun hasRecentTag(): Boolean {
        return recentTagData != null && (System.currentTimeMillis() - tagDetectedTime) < TAG_MEMORY_DURATION
    }

    private fun storeRecentTag(data: String?) {
        recentTagData = data
        tagDetectedTime = System.currentTimeMillis()
    }

    private fun clearRecentTag() {
        recentTagData = null
        tagDetectedTime = 0
    }

    fun enableForegroundDispatch() {
        nfcAdapter?.enableForegroundDispatch(activity, pendingIntent, null, null)
    }

    fun disableForegroundDispatch() {
        nfcAdapter?.disableForegroundDispatch(activity)
    }

    fun handleIntent(intent: Intent) {
        when (intent.action) {
            NfcAdapter.ACTION_NDEF_DISCOVERED,
            NfcAdapter.ACTION_TAG_DISCOVERED -> {
                val tag = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
                    intent.getParcelableExtra(NfcAdapter.EXTRA_TAG, Tag::class.java)
                } else {
                    @Suppress("DEPRECATION")
                    intent.getParcelableExtra<Tag>(NfcAdapter.EXTRA_TAG)
                }
                tag?.let { 
                    if (pendingWriteData != null) {
                        // Write mode - write the pending data
                        if (nfcManager.writeTag(it, pendingWriteData!!)) {
                            onStatusUpdate?.invoke("✅ Successfully wrote to tag!", false)
                            pendingWriteData = null
                        } else {
                            onStatusUpdate?.invoke("❌ Write failed - try again", false)
                        }
                    } else if (isReadingEnabled) {
                        // Read mode - read the tag
                        val data = nfcManager.readTag(it)
                        onTagDetected?.invoke(data)
                        data?.let { 
                            onStatusUpdate?.invoke("✅ Tag read successfully!", false)
                        } ?: onStatusUpdate?.invoke("❌ Tag detected but no data found", false)
                        isReadingEnabled = false
                    } else {
                        // Store tag for potential later use
                        val data = nfcManager.readTag(it)
                        storeRecentTag(data)
                        data?.let {
                            onStatusUpdate?.invoke("Tag detected - press 'Read NFC Tag' to load data", false)
                        }
                    }
                }
            }
        }
    }

    private fun showToast(message: String) {
        Toast.makeText(activity, message, Toast.LENGTH_SHORT).show()
    }
}
