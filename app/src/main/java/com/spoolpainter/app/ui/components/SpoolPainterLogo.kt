package com.spoolpainter.app.ui.components

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import com.spoolpainter.app.R
import androidx.compose.ui.unit.dp

@Composable
fun SpoolPainterLogo(
    color: Color,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .offset(x = (26).dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy((-18).dp)
    ) {
        Image(
            painter = painterResource(id = R.drawable.spool_logo),
            contentDescription = null,
            modifier = Modifier
                .height(125.dp)
                .size(200.dp),
            colorFilter = if (color == Color.Black) {
                ColorFilter.colorMatrix(
                    colorMatrix = androidx.compose.ui.graphics.ColorMatrix().apply {
                        setToScale(-1f, -1f, -1f, 1f)
                        set(0, 4, 255f)
                        set(1, 4, 255f)
                        set(2, 4, 255f)
                    }
                )
            } else {
                ColorFilter.tint(color, BlendMode.Modulate)
            },
            contentScale = ContentScale.Fit
        )
        
        Text(
            text = "Spool Painter",
            style = MaterialTheme.typography.headlineLarge,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onBackground,
            modifier = Modifier
                .offset(y = (15).dp)
                .offset(x = (-15).dp)
        )
    }
}
